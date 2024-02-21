import 'package:flutter/material.dart';
import '../base/models/events.dart';

class NewEvent extends StatefulWidget {
  const NewEvent({
    Key? key,
    required this.onEventCreated,
    required this.events, // to recieve the events list
  }) : super(key: key);

  final Function(Events) onEventCreated;
  final List<Events> events;

  @override
  // ignore: library_private_types_in_public_api
  _NewEventState createState() => _NewEventState();
}

class _NewEventState extends State<NewEvent> {
  late TextEditingController _titleController;
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _startTime = TimeOfDay.now();
  late TimeOfDay _endTime = TimeOfDay.now();
  late TextEditingController _noteController;
  String _selectedNotification = 'Set Notification Time';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2120),
    );

    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (selected != null && selected != _startTime) {
      setState(() {
        _startTime = selected;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (selected != null && selected != _endTime) {
      setState(() {
        _endTime = selected;
      });
    }
  }

  Future<void> _selectSpecificDateTime(BuildContext context) async {
    final DateTime? specificDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2120),
    );

    if (specificDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? specificTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (specificTime != null) {
        setState(() {
          _selectedDate = specificDate;
          _startTime = specificTime;
          _endTime = specificTime;

          String notificationTime = '';
          switch (_selectedNotification) {
            case '15 mins before':
              notificationTime =
                  '${specificDate.subtract(const Duration(minutes: 15))}';
              break;
            case '1 hour before':
              notificationTime =
                  '${specificDate.subtract(const Duration(hours: 1))}';
              break;
            case '1 day before':
              notificationTime =
                  '${specificDate.subtract(const Duration(days: 1))}';
              break;
            case 'Manual Selection':
              notificationTime = '$specificDate';
              break;
            default:
              notificationTime = 'No Notification';
          }

          _titleController.text += '\nNotification Time: $notificationTime';

          _noteController.text = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectStartTime(context),
                    child: Text(
                      'Start Time: ${_startTime.hour}:${_startTime.minute}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectStartTime(context),
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectEndTime(context),
                    child: Text(
                      'End Time: ${_endTime.hour}:${_endTime.minute}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectEndTime(context),
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedNotification,
              onChanged: (String? value) {
                setState(() {
                  _selectedNotification = value!;
                  if (_selectedNotification == 'Manual Selection') {
                    _selectSpecificDateTime(context);
                  }
                });
              },
              items: <String>[
                'Set Notification Time',
                '15 mins before',
                '1 hour before',
                '1 day before',
                'Manual Selection'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create an event object using entered data
                Events newEvent = Events(
                  title: _titleController.text,
                  startTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _startTime.hour,
                    _startTime.minute,
                  ),
                  endTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _endTime.hour,
                    _endTime.minute,
                  ),
                  note: _noteController.text,
                );

                //Calling the callback function to pass the new events
                widget.onEventCreated(newEvent);

                Navigator.pop(context);
              },
              child: const Icon(Icons.save),
            ),
          ],
        )),
      ),
    );
  }
}
