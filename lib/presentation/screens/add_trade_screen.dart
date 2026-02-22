import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/trade_entity.dart';
import '../providers/trade_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class AddTradeScreen extends ConsumerStatefulWidget {
  const AddTradeScreen({super.key});

  @override
  ConsumerState<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends ConsumerState<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String _marketType = 'Futures';
  String _direction = 'Long';

  final _pairController = TextEditingController();
  final _entryController = TextEditingController();
  final _exitController = TextEditingController();
  final _slController = TextEditingController();
  final _tpController = TextEditingController();
  final _sizeController = TextEditingController();
  final _leverageController = TextEditingController();
  final _slippageController = TextEditingController();
  final _feeController = TextEditingController();
  final _riskController = TextEditingController();
  final _notesController = TextEditingController();

  File? _screenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _screenshot = File(image.path);
      });
    }
  }

  void _saveTrade() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final user = ref.read(authProvider).value;
        if (user == null) {
          throw Exception('User session not found. Please log in again.');
        }

        double? entry = double.tryParse(_entryController.text);
        if (entry == null) throw Exception('Invalid Entry Price format');

        double? exit = _exitController.text.isNotEmpty
            ? double.tryParse(_exitController.text)
            : null;
        if (_exitController.text.isNotEmpty && exit == null) {
          throw Exception('Invalid Exit Price format');
        }

        double? size = double.tryParse(_sizeController.text);
        if (size == null) throw Exception('Invalid Position Size format');

        double? pnl;
        if (exit != null) {
          if (_direction == 'Long' || _direction == 'Buy') {
            pnl = (exit - entry) * size;
          } else {
            pnl = (entry - exit) * size;
          }
          if (_feeController.text.isNotEmpty) {
            double? feeValue = double.tryParse(_feeController.text);
            if (feeValue != null) {
              pnl -= feeValue;
            }
          }
        }

        final trade = TradeEntity(
          id: 0,
          userId: user.id,
          date: _selectedDate,
          pair: _pairController.text.toUpperCase(),
          marketType: _marketType,
          direction: _direction,
          entryPrice: entry,
          exitPrice: exit,
          stopLoss: double.tryParse(_slController.text),
          takeProfit: double.tryParse(_tpController.text),
          positionSize: size,
          leverage: _marketType == 'Futures'
              ? int.tryParse(_leverageController.text)
              : null,
          fee: double.tryParse(_feeController.text),
          riskPercentage: double.tryParse(_riskController.text),
          pnl: pnl,
          notes:
              _notesController.text +
              (_marketType == 'Spot DEX' && _slippageController.text.isNotEmpty
                  ? '\nSlippage: ${_slippageController.text}%'
                  : ''),
          screenshotPath: _screenshot?.path,
          createdAt: DateTime.now(),
        );

        await ref.read(tradesProvider.notifier).addTrade(trade);
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(
          'Record New Trade',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _saveTrade,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.check_rounded,
                              color: Colors.black.withValues(alpha: 0.9),
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Market Type & Direction
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trade Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Market',
                              value: _marketType,
                              items: const [
                                'Futures',
                                'Spot DEX',
                                'Crypto',
                                'Stock',
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _marketType = v!;
                                  // Update direction defaults
                                  if (_marketType == 'Spot DEX') {
                                    _direction = 'Buy';
                                  } else {
                                    _direction = 'Long';
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Direction',
                              value: _direction,
                              items: _marketType == 'Spot DEX'
                                  ? const ['Buy', 'Sell']
                                  : const ['Long', 'Short'],
                              onChanged: (v) => setState(() => _direction = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Trading Pair
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trading Pair',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pairController,
                        decoration: const InputDecoration(
                          labelText: 'e.g., BTC/USDT, ETH/USD',
                          prefixIcon: Icon(Icons.currency_bitcoin),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Entry & Exit Prices
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entry & Exit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _entryController,
                              decoration: const InputDecoration(
                                labelText: 'Entry Price',
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _exitController,
                              decoration: const InputDecoration(
                                labelText: 'Exit Price (Optional)',
                                prefixIcon: Icon(Icons.trending_down),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Position Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Position Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sizeController,
                              decoration: InputDecoration(
                                labelText: _marketType == 'Spot DEX'
                                    ? 'Amount / Buy'
                                    : 'Position Size',
                                prefixIcon: const Icon(Icons.layers),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          if (_marketType == 'Futures') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _leverageController,
                                decoration: const InputDecoration(
                                  labelText: 'Leverage (x)',
                                  prefixIcon: Icon(Icons.speed),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    (_marketType == 'Futures' &&
                                        (v == null || v.isEmpty))
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ] else if (_marketType == 'Spot DEX') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _slippageController,
                                decoration: const InputDecoration(
                                  labelText: 'Slippage %',
                                  prefixIcon: Icon(Icons.low_priority),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Risk Management
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Risk Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _slController,
                              decoration: const InputDecoration(
                                labelText: 'Stop Loss',
                                prefixIcon: Icon(Icons.shield),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tpController,
                              decoration: const InputDecoration(
                                labelText: 'Take Profit',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fees & Risk
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Costs & Risk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _feeController,
                              decoration: const InputDecoration(
                                labelText: 'Fees',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _riskController,
                              decoration: const InputDecoration(
                                labelText: 'Risk %',
                                prefixIcon: Icon(Icons.percent),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Trade Notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trade Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Add your trade notes here...',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trade Date & Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: AppTheme.getCardDecoration(),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                if (!context.mounted) return;
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    _selectedDate,
                                  ),
                                );
                                if (time != null) {
                                  setState(() {
                                    _selectedDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppTheme.accentColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat.yMd().add_Hm().format(
                                      _selectedDate,
                                    ),
                                    style: const TextStyle(
                                      color: AppTheme.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Screenshots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trade Screenshot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_screenshot != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _screenshot!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _screenshot = null),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          decoration: AppTheme.getCardDecoration(),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: AppTheme.accentColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tap to add screenshot',
                                      style: TextStyle(
                                        color: AppTheme.textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Optional - Add proof of your trade',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
