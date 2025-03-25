import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_management/components/bubble_dropdown.dart';
import 'package:hotel_management/components/button.dart';
import 'package:hotel_management/components/newmorphic_data_field.dart';

// Import your custom SliderFb3 widget here
import 'package:hotel_management/components/slider.dart';
import 'package:hotel_management/models/hotels.dart';
import 'package:hotel_management/models/tables.dart';
import 'package:hotel_management/pages/table_page.dart';

class TableBookingPage extends StatefulWidget {
  final Hotels hotel;

  const TableBookingPage({super.key, required this.hotel});

  @override
  State<TableBookingPage> createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  double _sliderValue = 1.0; // Initial slider value
  List<String> menuItems = ['Indoor', 'Outdoor', 'Buffet'];
  String? selectedTimeOption; // Selected option for the dropdown menu

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Book Table",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Table Booking",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: screenWidth *
                          0.08, // Adjust font size based on screen width
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete the form to get the table that best suits you",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  // Form content moved here
                  Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                        Text('Number of People:',
                            style: TextStyle(fontSize: 16)),
                        SliderFb3(
                          min: 1,
                          max: 6,
                          divisions: 5,
                          initialValue: _sliderValue,
                          onChange: (value) {
                            setState(() {
                              _sliderValue = value;
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text('Select Date', style: TextStyle(fontSize: 16)),
                        Container(
                          width: double
                              .infinity, // Make the dropdown take full width
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF757575), // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  16), // Add padding inside the container
                          child: DropdownButton<String>(
                            value: selectedTimeOption,
                            onChanged: (value) {
                              setState(() {
                                selectedTimeOption = value;
                              });
                            },
                            items: ['today', 'tomorrow', 'day_after']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: Text('Select an option'),
                            isExpanded:
                                true, // Ensure the dropdown button expands to fill the width
                            underline:
                                Container(), // Remove the default underline
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyButton(
                          text: 'Select Table',
                          onTap: () {
                            // Navigate to the SeatSelectionWidget with the selected time and number of people
                            final Tables table = Tables(
                                date: selectedTimeOption ?? 'No date selected',
                                people: _sliderValue.toString());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SeatSelectionWidget(
                                        hotel: widget.hotel, table: table)));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const Text(
                    "By continuing your confirm that you agree \nwith our Term and Condition",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);
