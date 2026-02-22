import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/trade_entity.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TradeDetailScreen extends StatelessWidget {
  final TradeEntity trade;

  const TradeDetailScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final isProfit = (trade.pnl ?? 0) >= 0;
    final pnlColor = trade.pnl == null
        ? Colors.grey
        : (isProfit ? AppTheme.successColor : AppTheme.errorColor);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(
          'Trade Details',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                decoration: AppTheme.getCardDecoration(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trade.pair,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trade.direction} • ${trade.marketType}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    trade.direction.toLowerCase() == 'long' ||
                                        trade.direction.toLowerCase() == 'buy'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              trade.pnl != null
                                  ? '\$${trade.pnl!.toStringAsFixed(2)}'
                                  : 'Open',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: pnlColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().add_jm().format(trade.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Entry/Exit Info
              const Text(
                'Execution Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.getCardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Entry Price',
                      '\$${trade.entryPrice.toStringAsFixed(4)}',
                    ),
                    if (trade.exitPrice != null)
                      _buildDetailRow(
                        'Exit Price',
                        '\$${trade.exitPrice!.toStringAsFixed(4)}',
                      ),
                    if (trade.stopLoss != null)
                      _buildDetailRow(
                        'Stop Loss',
                        '\$${trade.stopLoss!.toStringAsFixed(4)}',
                      ),
                    if (trade.takeProfit != null)
                      _buildDetailRow(
                        'Take Profit',
                        '\$${trade.takeProfit!.toStringAsFixed(4)}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Risk & Sizing
              const Text(
                'Position & Risk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.getCardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Position Size',
                      trade.positionSize.toString(),
                    ),
                    if (trade.leverage != null)
                      _buildDetailRow('Leverage', '${trade.leverage}x'),
                    if (trade.riskPercentage != null)
                      _buildDetailRow('Risk %', '${trade.riskPercentage}%'),
                    if (trade.fee != null)
                      _buildDetailRow(
                        'Fees',
                        '\$${trade.fee!.toStringAsFixed(2)}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notes section
              if (trade.notes != null && trade.notes!.isNotEmpty) ...[
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: AppTheme.getCardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    trade.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Screenshot
              if (trade.screenshotPath != null &&
                  trade.screenshotPath!.isNotEmpty) ...[
                const Text(
                  'Screenshot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(trade.screenshotPath!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(20),
                      color: AppTheme.cardDark,
                      child: const Center(
                        child: Text(
                          'Image not found or unavailable',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
