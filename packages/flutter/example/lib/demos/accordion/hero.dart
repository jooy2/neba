import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AccordionHero extends StatelessWidget {
  const AccordionHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaAccordion<String>(
        defaultValue: <String>['billing'],
        children: <Widget>[
          NebaAccordionItem<String>(
            value: 'billing',
            title: Text('How does billing work?'),
            subtitle: Text('Plans and invoices'),
            child: Text(
              'You are charged on the first of each month for the seats you had on the last day '
              'of the previous one. Adding a seat mid-month is prorated; removing one is credited.',
            ),
          ),
          NebaAccordionItem<String>(
            value: 'regions',
            title: Text('Where do builds run?'),
            subtitle: Text('Four regions'),
            child: Text(
              "Builds run in the region closest to the repository's default branch, and can be "
              'pinned to a single region per project.',
            ),
          ),
          NebaAccordionItem<String>(
            value: 'limits',
            title: Text('What are the limits?'),
            subtitle: Text('Per plan'),
            child: Text(
              'The free plan allows 400 build minutes a month. Paid plans are metered rather than '
              'capped.',
            ),
          ),
        ],
      ),
    );
  }
}
