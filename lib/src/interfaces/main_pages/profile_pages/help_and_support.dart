import 'package:DriveFormeDriver/src/interfaces/main_pages/trip_pages/raise_ticket.dart';
import 'package:flutter/material.dart';

// Preserve existing navigation links while sharing the ticket workflow.
// Category value is an API identifier (English); UI title uses support.tr().
class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const RaiseTicketPage(category: 'General Support');
}
