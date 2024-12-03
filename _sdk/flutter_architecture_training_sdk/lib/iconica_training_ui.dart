import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';

class CourseOverviewItem extends StatelessWidget {
  const CourseOverviewItem({
    required this.course,
    this.onTap,
    this.studentCounter,
    super.key,
  });

  final Course course;
  final Widget Function(BuildContext context)? studentCounter;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var counter = studentCounter?.call(context);
    counter ??= Text(
      "No Student count available",
      style: theme.textTheme.labelLarge,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.training.name,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(),
            ),
            const SizedBox(height: 8.0),
            Text(
              course.training.description,
            ),
            const SizedBox(height: 8),
            CourseOverviewItemDetail(
              index: "Trainer",
              value: course.trainer.user.user.firstName,
            ),
            const SizedBox(height: 4),
            CourseOverviewItemDetail(
              index: "Date",
              value: course.dates.first.toIso8601String().substring(0, 10),
            ),
            const SizedBox(height: 4),
            CourseOverviewItemDetail(
              index: "Language",
              value: course.language,
            ),
            const SizedBox(height: 4),
            counter,
          ],
        ),
      ),
    );
  }
}

class CourseOverviewItemDetail extends StatelessWidget {
  const CourseOverviewItemDetail({
    required this.index,
    required this.value,
    super.key,
  });

  final String index;
  final String value;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 128,
          child: Text(
            index,
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
