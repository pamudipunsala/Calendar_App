import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'new_event.dart';
import '../base/models/events.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime today = DateTime.now();
  List<Events> events = [];

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  void _onEventCreated(Events event) {
    setState(() {
      events.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigate to the new event creating UI
          final newEvent = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewEvent(
                        onEventCreated: _onEventCreated,
                        events: events,
                      )));
          if (newEvent != null && newEvent is Events) {
            _onEventCreated(newEvent);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: content(),
    );
  }

  Widget content() {
    Map<DateTime, List<String>> holidays = {
      //defining the holidays
      DateTime.utc(2024, 01, 15): ['Tamil Thai Pongal Day(P)'],
      DateTime.utc(2024, 01, 25): ['Duruthu Full Moon Poya Day(M)'],
      DateTime.utc(2024, 02, 4): ['National Day(P)'],
      DateTime.utc(2024, 02, 23): ['Navam Full Moon Poya Day(M)'],
      DateTime.utc(2024, 03, 8): ['Mahasivarathri Day(P)'],
      DateTime.utc(2024, 03, 24): ['Madin Full Moon Poya Day(M)'],
      DateTime.utc(2024, 03, 29): ['Good Friday(P)'],
      DateTime.utc(2024, 04, 12): ['Sinhala & Tamil New Year\'s Eve'],
      DateTime.utc(2024, 04, 13): ['Sinhala & Tamil New Year\'s Day'],
    };

    //Filter events based on the selected date
    List<Events> filteredEvents = events.where((event) {
      return isSameDay(event.startTime, today);
    }).toList();

    return Column(
      children: [
        TableCalendar(
          focusedDay: today,
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          availableGestures: AvailableGestures.all,
          selectedDayPredicate: (day) => isSameDay(day, today),
          firstDay: DateTime.utc(2010, 01, 01),
          lastDay: DateTime.utc(2030, 12, 31),
          onDaySelected: _onDaySelected,
          eventLoader: (date) {
            return holidays[date] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, dynamic events) {
              List<String> eventList =
                  events.cast<String>(); // Casting events to List<String>
              return Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 2),
                    ...eventList.map(
                      (event) => Text(
                        event,
                        style: const TextStyle(fontSize: 5),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  final backgroundColor =
                      index % 2 == 0 ? Colors.grey[200] : Colors.transparent;
                  return Container(
                    color: backgroundColor,
                    child: ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}',
                      ),
                    ),
                  );
                }))
      ],
    );
  }
}
