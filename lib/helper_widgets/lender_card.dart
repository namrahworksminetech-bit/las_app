import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:flutter/scheduler.dart';

class LenderCard extends StatefulWidget {
  final Lender lender;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSaving;
  final String? snackbarMessage;
  final String? lastSavedLenderId;  
  final String? lastSaveMessage;  
  final ValueChanged<double> onAmountSaved;
  final VoidCallback onContinue;

  const LenderCard({
    super.key,
    required this.lender,
    required this.isSelected,
    required this.onTap,
    required this.isSaving,
    required this.snackbarMessage,
    required this.lastSavedLenderId, 
    required this.lastSaveMessage,   
    required this.onAmountSaved,
    required this.onContinue,
  });
  @override
  State<LenderCard> createState() => _LenderCardState();
}

class _LenderCardState extends State<LenderCard> {
  bool _isEditing = false;
  late TextEditingController _amountController;
  final FocusNode _focusNode = FocusNode();
  final formatCurrency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.lender.loanAmount?.toStringAsFixed(0) ?? '0');
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  @override
void didUpdateWidget(covariant LenderCard oldWidget) {
  super.didUpdateWidget(oldWidget);

  // keep text in sync and other existing logic...
  if (!_isEditing &&
      (oldWidget.lender.loanAmount ) != (widget.lender.loanAmount ?? 0)) {
    _amountController.text = (widget.lender.loanAmount ?? 0).toStringAsFixed(0);
  }
  if (oldWidget.isSelected && !widget.isSelected && _isEditing) {
    _stopEditing(save: false);
  }

 final finishedSaving = oldWidget.isSaving && !widget.isSaving;

final isResultForThisLender =
    widget.lastSavedLenderId != null &&
    widget.lastSavedLenderId == widget.lender.id;

final hasMessage = widget.lastSaveMessage != null &&
    widget.lastSaveMessage!.trim().isNotEmpty;

// ONLY check if saving finished + message exists (remove messageChanged)
if (finishedSaving && isResultForThisLender && hasMessage) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final msg = widget.lastSaveMessage!;
    CSnackBar.show(
      context,
      msg,
      isError: msg.toLowerCase().contains('fail') || msg.toLowerCase().contains('error'),
    );
  });
}}
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _stopEditing(save: true);
    }
  }

  void _startEditing() {
    if (!widget.isSelected || widget.isSaving) return;
    setState(() {
      _isEditing = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _amountController.selection = TextSelection(
            baseOffset: 0, extentOffset: _amountController.text.length);
        _focusNode.requestFocus();
      });
    });
  }

  void _showError(String msg) {
    // safe to call here because this is user-initiated
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
void _stopEditing({required bool save}) {
  if (!_isEditing) return;

  if (!save) {
    _amountController.text =
        (widget.lender.loanAmount ?? 0).toStringAsFixed(0);
    setState(() => _isEditing = false);
    return; // 🆕 important patch
  }
    double? newAmount;
    if (save) {
      newAmount = double.tryParse(_amountController.text);
      if (newAmount == null || newAmount <= 0) {
        // invalid input
        _amountController.text = (widget.lender.loanAmount ?? 0).toStringAsFixed(0);
        _showError('Invalid amount entered');
        newAmount = null;
      } else {
        // VALIDATION: Ensure edited amount does not exceed lender.loanAmount
        // (as you specified: lender.loanAmount is the main amount that should not be exceeded)
        final double allowed = widget.lender.loanAmount ?? 0.0;
        if (allowed > 0 && newAmount > allowed) {
          final formattedAllowed = formatCurrency.format(allowed);
          _amountController.text = (widget.lender.loanAmount ?? 0).toStringAsFixed(0);

          _showError('Amount cannot exceed the limit of $formattedAllowed');
          newAmount = null;
        }
      }
    } else {
      _amountController.text = (widget.lender.loanAmount ?? 0).toStringAsFixed(0);
    }

    setState(() {
      _isEditing = false;
    });

    _focusNode.unfocus();

    if (newAmount != null) {
      widget.onAmountSaved(newAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Duration animDuration = Duration(milliseconds: 300);
    final Color cardBackgroundColor =
        widget.isSelected ? AppColors.black : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: animDuration,
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected ? AppColors.bPrimaryColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: widget.isSelected ? [/* ... */] : [],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.lender.logoAsset.isNotEmpty
                      ? Image.network(
                          widget.lender.logoAsset,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColors.bPrimaryColor,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.business, color: Colors.grey, size: 24),
                        )
                      : const Icon(Icons.business, color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.lender.name ?? '',
                    style: const TextStyle(
                        color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                if ((widget.lender.tag ?? '').isNotEmpty)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bPrimaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.lender.tag ?? '',
                        style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('Interest Rate', '${widget.lender.interestRate}%'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Loan Amount',
                        style: TextStyle(color: AppColors.bSecondaryColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: animDuration,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _isEditing
                          ? SizedBox(
                              key: const ValueKey('amount_textfield'),
                              width: 100,
                              child: IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  focusNode: _focusNode,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: false),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.start,
                                  cursorColor: AppColors.bPrimaryColor,
                                  decoration: const InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                                    enabledBorder:
                                        UnderlineInputBorder(borderSide: BorderSide(color: AppColors.bSecondaryColor)),
                                    focusedBorder:
                                        UnderlineInputBorder(borderSide: BorderSide(color: AppColors.bPrimaryColor)),
                                  ),
                                  onSubmitted: (_) => _stopEditing(save: true),
                                ),
                              ),
                            )
                          : Text(
                              key: const ValueKey('amount_text'),
                              formatCurrency.format(widget.lender.loanAmount ?? 0),
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                    ),
                  ],
                ),
                _buildDetailColumn('Pledgeable MFs', '${widget.lender.pledgeableMFs ?? ''}'),
              ],
            ),
            AnimatedSize(
              duration: animDuration,
              curve: Curves.easeInOut,
              child: widget.isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CButton(
                              text: _isEditing ? 'Save Amount' : 'Edit Loan Amount',
                              onPressed: widget.isSaving
                                  ? null
                                  : (_isEditing ? () => _stopEditing(save: true) : _startEditing),
                              type: ButtonType.secondaryGrey,
                              suffixIcon: widget.isSaving
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                       Expanded(
  child: CButton(
    text: 'Continue',
    onPressed: widget.onContinue,
    type: ButtonType.primaryWhite,
    suffixIcon:
        const Icon(Icons.arrow_forward, color: AppColors.black, size: 18),
  ),
),

                        ],
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.bSecondaryColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
