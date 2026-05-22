package fr.antinote.antinote_app.calendar

import android.content.ContentProviderOperation
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.CalendarContract
import androidx.annotation.RequiresApi
import androidx.core.database.getStringOrNull
import fr.antinote.antinote_app.auth.LoginManager
import fr.antinote.studies_management.antinote_app.pigeon_posts.*
import java.time.OffsetDateTime
import java.time.ZoneOffset
import kotlin.time.ExperimentalTime
import kotlin.time.Instant
import kotlin.time.toKotlinInstant

class CalendarManager(private val context: Context) : NativeCalendarManager {
    companion object {
        private const val CALENDAR_VERSION = CalendarContract.Calendars.CAL_SYNC1
        private const val CALENDAR_ACCOUNT_UID = CalendarContract.Calendars.CAL_SYNC2
        private const val CALENDAR_RESOURCE_VISUAL_ID = CalendarContract.Calendars.CAL_SYNC3

        private const val EVENT_VERSION = CalendarContract.Events.SYNC_DATA1
        private const val EVENT_VISUAL_ID = CalendarContract.Events.SYNC_DATA2
        private const val EVENT_ENTRY_TYPE = CalendarContract.Events.SYNC_DATA3

        private const val VERSION_1 = "1"
        private const val LATEST_VERSION = VERSION_1
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @OptIn(ExperimentalTime::class)
    private fun parseDateTime(raw: String): Instant {
        val year = Regex("(?<year>\\d{4})")
        val month = Regex("(?<month>\\d{2})")
        val day = Regex("(?<day>\\d{2})")
        val hour = Regex("(?<hour>\\d{2})")
        val minute = Regex("(?<minute>\\d{2})")
        val second = Regex("(?<second>\\d{2})")
        val regEx = Regex("^${year}${month}${day}T${hour}${minute}${second}Z")

        val match = regEx.find(raw)!!

        return OffsetDateTime.of(
            match.groups["year"]!!.value.toInt(),
            match.groups["month"]!!.value.toInt(),
            match.groups["day"]!!.value.toInt(),
            match.groups["hour"]!!.value.toInt(),
            match.groups["minute"]!!.value.toInt(),
            match.groups["second"]!!.value.toInt(),
            0,
            ZoneOffset.UTC
        ).toInstant().toKotlinInstant()
    }

    fun createUri(base: Uri, accountUid: String): Uri {
        val account = LoginManager.accountForUid(context, accountUid)
        return base.buildUpon().appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, account.name)
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_TYPE, account.type).build()
    }

    @OptIn(ExperimentalTime::class)
    @RequiresApi(Build.VERSION_CODES.O)
    override fun listExisting(
        accountUid: String, calendarId: Long
    ): List<ExistingCalendarEventEntry> {
        val cursor = context.contentResolver.query(
            createUri(CalendarContract.Events.CONTENT_URI, accountUid), arrayOf(
                CalendarContract.Events._ID,
                CalendarContract.Events.ORIGINAL_SYNC_ID,
                CalendarContract.Events.CUSTOM_APP_URI,
                CalendarContract.Events.RRULE,
                CalendarContract.Events.DTSTART,
                CalendarContract.Events.EXDATE,
                CalendarContract.Events.DELETED,

                EVENT_VERSION,
                EVENT_VISUAL_ID,
                EVENT_ENTRY_TYPE
            ), "${CalendarContract.Events.CALENDAR_ID} = ?", arrayOf(calendarId.toString()), null
        )

        if (cursor == null) {
            throw SecurityException("Could not query events table (is permission granted?)")
        }

        val entries = mutableListOf<ExistingCalendarEventEntry>()

        cursor.use {
            val idIndex = it.getColumnIndex(CalendarContract.Events._ID)
            val originalSyncIdIndex = it.getColumnIndex(CalendarContract.Events.ORIGINAL_SYNC_ID)
            val eventRruleIndex = it.getColumnIndex(CalendarContract.Events.RRULE)
            val eventStartIndex = it.getColumnIndex(CalendarContract.Events.DTSTART)
            val eventExceptionsIndex = it.getColumnIndex(CalendarContract.Events.EXDATE)
            val deletedIndex = it.getColumnIndex(CalendarContract.Events.DELETED)

            val versionIndex = it.getColumnIndex(EVENT_VERSION)
            val visualIdIndex = it.getColumnIndex(EVENT_VISUAL_ID)
            val entryTypeIndex = it.getColumnIndex(EVENT_ENTRY_TYPE)
            while (it.moveToNext()) {
                if (it.getInt(deletedIndex) != 0) continue

                when (val version = it.getString(versionIndex)) {
                    VERSION_1 -> {
                        val id = it.getLong(idIndex)
                        val originalSyncId = it.getStringOrNull(originalSyncIdIndex)
                        val eventRrule = it.getStringOrNull(eventRruleIndex)
                        val eventStart = it.getLong(eventStartIndex)
                        val eventExceptions = it.getStringOrNull(eventExceptionsIndex)

                        val eventVisualId = it.getString(visualIdIndex)
                        val eventEntryType = it.getInt(entryTypeIndex)

                        val entry = ExistingCalendarEventEntry(
                            id = id,
                            originalVisualId = originalSyncId,
                            accountUid = accountUid,
                            calendarId = calendarId,
                            visualId = eventVisualId,
                            rrule = eventRrule ?: "",
                            startTime = eventStart,
                            exceptions = eventExceptions?.split(",")?.filter { s -> s.trim().isNotEmpty() }
                                ?.map { ex -> parseDateTime(ex).toEpochMilliseconds() } ?: listOf(),
                            entryType = CalendarEventEntryType.ofRaw(eventEntryType)!!,
                        )

                        entries.add(entry)
                    }

                    else -> throw IllegalStateException("Unknown version for event: $version")
                }
            }
        }

        return entries
    }

    private fun mainInstanceContentValues(entry: NewRecurringCalendarEventEntry): ContentValues {
        return ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, entry.calendarId)
            put(CalendarContract.Events._SYNC_ID, entry.visualId)
            if (entry.rrule != null) {
                put(CalendarContract.Events.RRULE, entry.rrule)
            } else {
                put(CalendarContract.Events.RDATE, entry.rdate)
            }
            put(CalendarContract.Events.DTSTART, entry.mockStart)
            if (entry.exdate.isNotEmpty()) {
                put(CalendarContract.Events.EXDATE, entry.exdate)
            }

            put(CalendarContract.Events.DURATION, entry.duration)
            put(
                CalendarContract.Events.EVENT_TIMEZONE, /*TimeZone.getAvailableIDs().first()*/
                "Europe/Paris"
            )
            put(CalendarContract.Events.EVENT_COLOR, entry.color)
            put(CalendarContract.Events.TITLE, entry.title)
            put(CalendarContract.Events.DESCRIPTION, entry.descriptions)
            put(CalendarContract.Events.EVENT_LOCATION, entry.location)
            put(CalendarContract.Events.GUESTS_CAN_INVITE_OTHERS, 0)
            put(
                CalendarContract.Events.AVAILABILITY,
                if (entry.canceled) CalendarContract.Events.AVAILABILITY_FREE else CalendarContract.Events.AVAILABILITY_BUSY
            )
            put(
                CalendarContract.Events.SELF_ATTENDEE_STATUS,
                if (entry.canceled) CalendarContract.Attendees.ATTENDEE_STATUS_DECLINED else CalendarContract.Attendees.ATTENDEE_STATUS_ACCEPTED
            )

            put(CalendarContract.Events.DIRTY, 0)
            put(CalendarContract.Events.ALL_DAY, 0)

            put(EVENT_VERSION, LATEST_VERSION)
            put(EVENT_VISUAL_ID, entry.visualId)
            put(EVENT_ENTRY_TYPE, entry.entryType.raw)
        }
    }

    private fun exceptionContentValues(
        entry: NewExceptionCalendarEventEntry, originalEntry: NewRecurringCalendarEventEntry, originalId: Long
    ): ContentValues {
        return ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, originalEntry.calendarId)

            put(CalendarContract.Events.ORIGINAL_ID, originalId)
            put(CalendarContract.Events.ORIGINAL_ALL_DAY, 0)
            put(CalendarContract.Events.ORIGINAL_INSTANCE_TIME, entry.start)
            put(
                CalendarContract.Events.ORIGINAL_SYNC_ID, originalEntry.visualId
            )
            put(CalendarContract.Events.DTSTART, entry.start)
            put(CalendarContract.Events.DTEND, entry.end)
            put(CalendarContract.Events.LAST_DATE, entry.end)

            put(
                CalendarContract.Events.EVENT_TIMEZONE, "Europe/Paris"
            )
            put(CalendarContract.Events.EVENT_COLOR, entry.color)
            put(CalendarContract.Events.TITLE, entry.title)
            put(CalendarContract.Events.DESCRIPTION, entry.descriptions)
            put(CalendarContract.Events.EVENT_LOCATION, entry.location)
            put(
                CalendarContract.Events.AVAILABILITY,
                if (entry.canceled) CalendarContract.Events.AVAILABILITY_FREE else CalendarContract.Events.AVAILABILITY_BUSY
            )
            put(
                CalendarContract.Events.SELF_ATTENDEE_STATUS,
                if (entry.canceled) CalendarContract.Attendees.ATTENDEE_STATUS_DECLINED else CalendarContract.Attendees.ATTENDEE_STATUS_ACCEPTED
            )

            put(CalendarContract.Events.DIRTY, 0)
            put(CalendarContract.Events.ALL_DAY, 0)

            put(EVENT_VERSION, LATEST_VERSION)
            put(EVENT_VISUAL_ID, entry.visualId)
            put(EVENT_ENTRY_TYPE, originalEntry.entryType.raw)
        }
    }

    private fun populateAttendees(
        attendeesUrl: Uri, eventId: Long, attendees: List<AttendeeEntry>
    ) {
        context.contentResolver.bulkInsert(attendeesUrl, attendees.map { attendee ->
            ContentValues().apply {
                put(CalendarContract.Attendees.EVENT_ID, eventId)
                put(CalendarContract.Attendees.ATTENDEE_NAME, attendee.name)
                put(
                    CalendarContract.Attendees.ATTENDEE_EMAIL, "${attendee.visualId}@${attendee.instanceDomain}"
                )
                put(
                    CalendarContract.Attendees.ATTENDEE_RELATIONSHIP, when (attendee.type) {
                        AttendeeType.GROUP -> CalendarContract.Attendees.RELATIONSHIP_ATTENDEE
                        AttendeeType.CLASSROOM -> CalendarContract.Attendees.RELATIONSHIP_NONE
                        AttendeeType.HELPER -> CalendarContract.Attendees.RELATIONSHIP_PERFORMER
                        AttendeeType.TEACHER -> CalendarContract.Attendees.RELATIONSHIP_SPEAKER
                    }
                )
                put(
                    CalendarContract.Attendees.ATTENDEE_STATUS,
                    if (attendee.type == AttendeeType.CLASSROOM) CalendarContract.Attendees.ATTENDEE_STATUS_NONE else CalendarContract.Attendees.ATTENDEE_STATUS_ACCEPTED
                )
                put(
                    CalendarContract.Attendees.ATTENDEE_TYPE, when (attendee.type) {
                        AttendeeType.TEACHER, AttendeeType.GROUP -> CalendarContract.Attendees.TYPE_REQUIRED
                        AttendeeType.CLASSROOM -> CalendarContract.Attendees.TYPE_RESOURCE
                        AttendeeType.HELPER -> CalendarContract.Attendees.TYPE_OPTIONAL
                    }
                )

                put(CalendarContract.Attendees.ATTENDEE_IDENTITY, attendee.visualId)
                put(
                    CalendarContract.Attendees.ATTENDEE_ID_NAMESPACE,
                    attendee.instanceDomain.split('.').reversed().joinToString(".")
                )

            }
        }.toTypedArray())
    }


    override fun insertNew(entries: List<NewRecurringCalendarEventEntry>) {
        val perAccount = mutableMapOf<String, MutableList<NewRecurringCalendarEventEntry>>()
        for (entry in entries) {
            if (perAccount.containsKey(entry.accountUid)) {
                perAccount[entry.accountUid]!!.add(entry)
            } else {
                perAccount[entry.accountUid] = mutableListOf(entry)
            }
        }

        for (pair in perAccount.entries) {
            val withExceptions = pair.value.filter { it.exceptions.isNotEmpty() || it.attendees.isNotEmpty() }

            val eventsUrl = createUri(
                CalendarContract.Events.CONTENT_URI, pair.key
            )
            val attendeesUrl = createUri(CalendarContract.Attendees.CONTENT_URI, pair.key)

            for (entry in withExceptions) {
                val values = mainInstanceContentValues(entry)
                val idUrl = context.contentResolver.insert(eventsUrl, values)

                if (idUrl == null) {
                    println("Failed to add event...")
                    continue
                }
                val id = ContentUris.parseId(idUrl)

                populateAttendees(attendeesUrl, id, entry.attendees)

                for (exception in entry.exceptions) {
                    val values = exceptionContentValues(
                        exception, entry, id
                    )

                    val exceptionIdUrl = context.contentResolver.insert(eventsUrl, values)
                    if (exceptionIdUrl == null) {
                        println("Failed to add event...")
                        continue
                    }
                    val exceptionId = ContentUris.parseId(exceptionIdUrl)
                    populateAttendees(attendeesUrl, exceptionId, entry.attendees)
                }
            }
        }
    }

    override fun deleteExisting(entries: List<ExistingCalendarEventEntry>) {
        val operations = arrayListOf<ContentProviderOperation>()
        for (entry in entries) {
            val rawEventId = entry.id.toString()

            operations.add(
                ContentProviderOperation.newDelete(CalendarContract.Events.CONTENT_URI).withSelection(
                    "${CalendarContract.Events._ID} = ? OR ${CalendarContract.Events.ORIGINAL_ID} = ?",
                    arrayOf(rawEventId, rawEventId)
                ).build()
            )
            operations.add(
                ContentProviderOperation.newDelete(CalendarContract.Attendees.CONTENT_URI).withSelection(
                    "${CalendarContract.Attendees.EVENT_ID} = ?", arrayOf(rawEventId)
                ).build()
            )
        }

        println("Deleting ${operations.size} events...")
        context.contentResolver.applyBatch(CalendarContract.AUTHORITY, operations)
    }

    override fun listCalendars(accountUid: String): List<ExistingCalendarEntry> {
        val cursor = context.contentResolver.query(
            createUri(CalendarContract.Calendars.CONTENT_URI, accountUid), arrayOf(
                CalendarContract.Calendars._ID,
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
                CalendarContract.Calendars.CALENDAR_COLOR,
                CalendarContract.Calendars.DELETED,
                CALENDAR_VERSION,
                CALENDAR_ACCOUNT_UID,
                CALENDAR_RESOURCE_VISUAL_ID
            ), null, null, null
        )

        if (cursor == null) {
            throw SecurityException("Could not query events table (is permission granted?)")
        }

        val entries = mutableListOf<ExistingCalendarEntry>()

        cursor.use {
            val calendarIdIndex = it.getColumnIndex(CalendarContract.Calendars._ID)
            val calendarNameIndex = it.getColumnIndex(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME)
            val calendarColorIndex = it.getColumnIndex(CalendarContract.Calendars.CALENDAR_COLOR)
            val deletedIndex = it.getColumnIndex(CalendarContract.Calendars.DELETED)
            val versionIndex = it.getColumnIndex(CALENDAR_VERSION)
            val calendarAccountUidIndex = it.getColumnIndex(CALENDAR_ACCOUNT_UID)
            val resourceVisualIdIndex = it.getColumnIndex(CALENDAR_RESOURCE_VISUAL_ID)
            while (it.moveToNext()) {
                if (it.getInt(deletedIndex) != 0) continue

                when (val version = it.getString(versionIndex)) {
                    VERSION_1 -> {
                        val calendarId = it.getLong(calendarIdIndex)
                        val accountUid = it.getString(calendarAccountUidIndex)
                        val resourceVisualId = it.getString(resourceVisualIdIndex)
                        val calendarName = it.getString(calendarNameIndex)
                        val calendarColor = it.getLong(calendarColorIndex)

                        entries.add(
                            ExistingCalendarEntry(
                                accountUid = accountUid,
                                id = calendarId,
                                displayName = calendarName,
                                color = calendarColor,
                                resourceVisualId = resourceVisualId
                            )
                        )
                    }

                    else -> throw IllegalStateException("Unknown version for event: $version")
                }
            }
        }

        return entries
    }

    override fun deleteCalendar(accountUid: String, calendarId: Long) {
        val deletedCalendars = context.contentResolver.delete(
            ContentUris.withAppendedId(
                createUri(
                    CalendarContract.Calendars.CONTENT_URI, accountUid
                ), calendarId
            ), null, null
        )
        println("Deleted $deletedCalendars calendars")
    }

    override fun insertNewCalendar(calendar: NewCalendarEntry): ExistingCalendarEntry {
        val account = LoginManager.accountForUid(context, calendar.accountUid)
        val createdCalendar = context.contentResolver.insert(
            createUri(
                CalendarContract.Calendars.CONTENT_URI, calendar.accountUid
            ), ContentValues().apply {
                put(CalendarContract.Calendars.ACCOUNT_NAME, account.name)
                put(CalendarContract.Calendars.ACCOUNT_TYPE, account.type)
                put(
                    CalendarContract.Calendars.NAME, calendar.accountUid + '_' + calendar.resourceVisualId
                )
                put(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, calendar.displayName)
                put(CalendarContract.Calendars.CALENDAR_COLOR, calendar.color)
                // Needs to be at least CAL_ACCESS_CONTRIBUTOR to be used in an AutomaticZenRule.
                // See : https://cs.android.com/android/platform/superproject/+/android-latest-release:frameworks/base/services/core/java/com/android/server/notification/CalendarTracker.java;l=98-100;drc=1d5156d9cc4d8d64f331122ef2336752e263cce5
                put(
                    CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL, CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR
                )
                put(CalendarContract.Calendars.OWNER_ACCOUNT, account.name)
                put(CalendarContract.Calendars.CAN_ORGANIZER_RESPOND, 0)
                put(CalendarContract.Calendars.SYNC_EVENTS, 1)
                put(CALENDAR_VERSION, LATEST_VERSION)
                put(CALENDAR_ACCOUNT_UID, calendar.accountUid)
                put(CALENDAR_RESOURCE_VISUAL_ID, calendar.resourceVisualId)
            })

        if (createdCalendar == null) {
            throw NullPointerException("Couldn't create calendar, see logs for more detail.")
        }

        val calendarId = ContentUris.parseId(createdCalendar)

        return ExistingCalendarEntry(
            accountUid = calendar.accountUid,
            resourceVisualId = calendar.resourceVisualId,
            id = calendarId,
            displayName = account.name,
            color = calendar.color,
        )
    }
}