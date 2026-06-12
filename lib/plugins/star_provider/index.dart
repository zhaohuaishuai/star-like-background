import 'package:flutter/material.dart';


class StarProvider<T extends ChangeNotifier> extends StatefulWidget {
  final Widget child; 
  final T Function(BuildContext context) create;
  const StarProvider({ required this.child,required this.create,super.key});

  @override
  State<StarProvider> createState() => _StarProviderState();
}

class _StarProviderState extends State<StarProvider> {
  @override
  Widget build(BuildContext context) {
    final model = widget.create(context);  
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        return StarProviderWidget(model: model,child:widget.child);
      } 
    );
  }
}

 

class StarProviderWidget<T extends ChangeNotifier> extends InheritedWidget {
  final T model; 
  const StarProviderWidget({required this.model, required super.child,super.key});
 
  static of<T extends ChangeNotifier>(BuildContext context){
    final StarProviderWidget<T>? result = context.dependOnInheritedWidgetOfExactType<StarProviderWidget<T>>(); 
    return result?.model;
  }
 
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) { 
    
     return true;
  }

}



extension StarProviderExtension on BuildContext{
  T watch<T extends ChangeNotifier>(){
      return StarProviderWidget.of<T>(this);
  }
}