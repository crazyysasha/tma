part of '../../twa.dart';

class StoryShareParams extends Equatable {
  final String? text;

  final StoryWidgetLink? widgetLink;

  const StoryShareParams({required this.text, required this.widgetLink});
  @override
  List<String> get props => ["text: $text", "widgetLink: $widgetLink"];
}

class StoryWidgetLink extends Equatable {
  final String url;
  final String? name;

  const StoryWidgetLink({required this.url, required this.name});

  @override
  List<String> get props => ["url: $url", "name: $name"];
}
