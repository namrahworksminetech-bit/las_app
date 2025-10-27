

import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart'; 

class SelectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconPath; 
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with TickerProviderStateMixin {
  
  late AnimationController _popAnimationController;
  late Animation<double> _scaleAnimation;
  
  

  @override
  void initState() {
    super.initState();
    _popAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), 
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate( 
      CurvedAnimation(parent: _popAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant SelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _popAnimationController.forward();
      } else {
        _popAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _popAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    const Duration animDuration = Duration(milliseconds: 300);

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition( 
        scale: _scaleAnimation,
        child: AnimatedContainer( 
          duration: animDuration,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.black, 
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.borderPrimaryColor
                  : AppColors.bSecondaryColor,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.borderPrimaryColor.withOpacity(0.5),
                      spreadRadius: 2.0,
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              
              AnimatedSize( 
                duration: animDuration,
                curve: Curves.easeInOut,
                child: AnimatedOpacity( 
                  duration: animDuration,
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  child: widget.isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Image.asset(
                            widget.iconPath,
                            width: 40,
                            height: 40,
                          ),
                        )
                      : const SizedBox(width: 0), 
                ),
              ),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    AnimatedSize(
                      duration: animDuration,
                      curve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      child: AnimatedOpacity(
                        duration: animDuration,
                        opacity: widget.isSelected ? 1.0 : 0.0,
                        child: widget.isSelected
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  widget.subtitle,
                                  maxLines: 2, 
                                  style: const TextStyle(
                                    color: AppColors.bSecondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 0), 
                      ),
                    ),
                  ],
                ),
              ),


              AnimatedCrossFade(
                duration: animDuration,
                crossFadeState: widget.isSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  key: const ValueKey('selected_radio'),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.borderPrimaryColor, 
                  ),
                ),
                secondChild: Container( 
                  key: const ValueKey('unselected_radio'),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppColors.bSecondaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}