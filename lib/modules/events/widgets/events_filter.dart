import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class EventFilter extends StatelessWidget {
  final Function(String, String) onApply;

  const EventFilter({super.key, required this.onApply});

  @override
  Widget build(BuildContext context) {
    String selectedCity = 'Jakarta';
    String selectedDate = 'all';

    return Positioned(
      top: 190,
      left: 20,
      right: 20,
      child: Material(
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
              const Text("Location",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi']
                    .map((city) {
                  return ChoiceChip(
                    label: Text(city),
                    selected: selectedCity == city,
                    onSelected: (_) => selectedCity = city,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Date",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['soon', 'later'].map((f) {
                  return ChoiceChip(
                    label: Text(f == 'soon' ? 'Soon' : 'Later'),
                    selected: selectedDate == f,
                    onSelected: (_) => selectedDate = f,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onApply(selectedCity, selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                ),
                child: const Text("Apply"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
