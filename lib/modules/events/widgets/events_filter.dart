import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class EventFilter extends StatefulWidget {
  final Function(String, String) onApply;
  const EventFilter({super.key, required this.onApply});

  @override
  State<EventFilter> createState() => _EventFilterState();
}

class _EventFilterState extends State<EventFilter> {
  String selectedCity = '';
  String selectedDate = 'all';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi']
                  .map((city) => ChoiceChip(
                        label: Text(city),
                        selected: selectedCity == city,
                        onSelected: (_) {
                          setState(() {
                            selectedCity = city;
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['soon', 'later'].map((f) {
                return ChoiceChip(
                  label: Text(f == 'soon' ? 'Soon' : 'Later'),
                  selected: selectedDate == f,
                  onSelected: (_) {
                    setState(() {
                      selectedDate = f;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onApply(selectedCity, selectedDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
              ),
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }
}
