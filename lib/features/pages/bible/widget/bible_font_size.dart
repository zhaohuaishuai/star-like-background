import 'package:flutter/material.dart';
import 'package:m/features/pages/bible/model/bible_model.dart';
class BibleFontSize extends StatefulWidget {
  final double fontSize;
  final Function(double) onFontSizeChanged;
  const BibleFontSize({super.key, required this.fontSize,required this.onFontSizeChanged}); 

  @override
  State<BibleFontSize> createState() => _BibleFontSizeState();
}

class _BibleFontSizeState extends State<BibleFontSize> {
  void _showFontSizeDialog(BuildContext context) {
       
      
    showDialog(
      context: context,
      builder: (BuildContext context) { 
        return AlertDialog(
          title: const Text('调整字体大小'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: widget.fontSize,
                    min: BibleModel.fontSizeMin,
                    max: BibleModel.fontSizeMax,
                    divisions: 14,
                    label: '${widget.fontSize.round()}',
                    onChanged: (double value) { 
                     widget.onFontSizeChanged(value);
                     setState(() {
                      
                     });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.format_size),
      onPressed: () => _showFontSizeDialog(context),
      tooltip: '调整字体大小',
    );
  }
}