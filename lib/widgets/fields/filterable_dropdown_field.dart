import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FilterableDropdownField<T> extends StatefulWidget {
  final SelectFieldBloc<T, dynamic> fieldBloc;
  final InputDecoration decoration;
  final Widget Function(BuildContext, T) itemBuilder;

  const FilterableDropdownField({
    Key? key,
    required this.fieldBloc,
    required this.decoration,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _FilterableDropdownFieldState<T> createState() =>
      _FilterableDropdownFieldState<T>();
}

class _FilterableDropdownFieldState<T> extends State<FilterableDropdownField<T>> {
  late List<T> filteredItems;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.fieldBloc.state.items;
    searchController = TextEditingController();
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.fieldBloc.state.items
          .where((item) =>
              item.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    widget.fieldBloc.updateItems(filteredItems);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownFieldBlocBuilder<T>(
      selectFieldBloc: widget.fieldBloc,
      decoration: widget.decoration,
      itemBuilder: (context, value) {
        // Jeśli wartość to specjalna oznaczona wartość (pole wyszukiwania)
        if (value == null) {
          return FieldItem(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          );
        }
        // Renderowanie standardowych elementów listy
        return FieldItem(
          child: widget.itemBuilder(context, value),
        );
      },
      // Dodajemy pole wyszukiwania jako pierwszy element do SelectFieldBloc
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
