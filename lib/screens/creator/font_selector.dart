import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../rehmat.dart';

class FontSelector extends StatefulWidget {

  const FontSelector({Key? key}) : super(key: key);

  @override
  _FontSelectorState createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {

  late Map<String, TextStyle> data;

  late int totalFonts;

  @override
  void initState() {
    totalFonts = GoogleFonts.asMap().length;
    data = {};
    for (int i = 0; i < 30; i++) {
      String font = GoogleFonts.asMap().keys.toList()[i];
      data[font] = GoogleFonts.asMap()[font]!.call();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [

          RenderAppBar(
            title: Text('Fonts'),
            actions: [
              IconButton(
                onPressed: () => showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                    hintText: 'Search Google Fonts',
                    onSelect: (font) {
                      Navigator.of(context).pop(font);
                    }
                  )
                ),
                icon: Icon(CupertinoIcons.search)
              )
            ],
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _FontPreviewBuilder(
                name: data.keys.toList()[index],
                family: data.values.toList()[index].fontFamily ?? 'Roboto',
                onTap: () => Navigator.of(context).pop(data.keys.toList()[index]),
              ),
              childCount: data.length > 30 ? 30 : data.length,
            )
          ),
          
        ],
      ),
    );
  }

  void filter(String _query) {
    data = {};
    for (String _font in GoogleFonts.asMap().keys) {
      String font = _font.toLowerCase().trim();
      String query = _query.toLowerCase().trim();
      if (font.contains(query) || font.startsWith(query) || font.endsWith(query)) {
        data[_font] = GoogleFonts.asMap()[_font]!.call();
      }
    }
    setState(() { });
  }

}

class CustomSearchDelegate extends SearchDelegate {

  CustomSearchDelegate({
    required String hintText,
    required this.onSelect
  }) : super(
    searchFieldLabel: hintText,
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
  );

  final void Function(String style) onSelect;
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(RenderIcons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(CupertinoIcons.arrow_turn_up_left),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none
      )
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }
    
    // Search

    Map<String, TextStyle> data = {};
    for (String _font in GoogleFonts.asMap().keys) {
      String font = _font.toLowerCase().trim();
      String _query = query.toLowerCase().trim();
      if (font.contains(_query) || font.startsWith(_query) || font.endsWith(_query)) {
        data[_font] = GoogleFonts.asMap()[_font]!.call();
      }
    }

    if (data.isEmpty) return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'No fonts found for "$query"',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        ],
      ),
    );

    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => _FontPreviewBuilder(
        name: data.keys.toList()[index],
        family: data.values.toList()[index].fontFamily ?? 'Roboto',
        onTap: () {
          String font = data.keys.toList()[index];
          Navigator.of(context).pop();
          onSelect(font);
        },
      ),
    );

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> results = [];
    for (String _font in GoogleFonts.asMap().keys) {
      String font = _font.toLowerCase().trim();
      String _query = query.toLowerCase().trim();
      if (font.contains(_query) || font.startsWith(_query) || font.endsWith(_query)) {
        results.add(_font);
      }
    }
    if (query.length < 2) return Container();
    return ListView.separated(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(results[index]),
        tileColor: Palette.of(context).surface,
        onTap: () {
          query = results[index];
          showResults(context);
        },
        trailing: Icon(RenderIcons.arrow_right),
      ),
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
    );
  }
}

class _FontPreviewBuilder extends StatelessWidget {

  const _FontPreviewBuilder({Key? key, required this.name, required this.family, required this.onTap}) : super(key: key);

  final String name;
  final String family;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Palette.of(context).surfaceContainerLow,
            border: Border.all(
              color: Palette.of(context).outline.withValues(alpha: 0.1)
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Divider(
                endIndent: 6,
                indent: 6,
              ),
              Text(
                [
                  'Every great design begins with an even better story.',
                  'Design is thinking made visual.',
                  'Creativity is intelligence having fun.',
                  'Good design is Good business.',
                  'Design adds value faster than it adds costs.',
                  'Make it simple, but significant.',
                  'The alternative to good design is always bad design. There is no such thing as no design.'
                ].getRandom(),
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontFamily: family
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}