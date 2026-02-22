import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trade_entity.dart';
import '../../domain/repositories/trade_repository.dart';
import '../../data/repositories/trade_repository_impl.dart';
import '../../data/database/isar_service.dart';
import '../../domain/entities/trade_filter.dart';
import 'auth_provider.dart';

final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  return TradeRepositoryImpl(IsarService());
});

final tradesProvider = AsyncNotifierProvider<TradesNotifier, List<TradeEntity>>(
  () {
    return TradesNotifier();
  },
);

class TradesNotifier extends AsyncNotifier<List<TradeEntity>> {
  late TradeRepository _repository;
  TradeFilter _currentFilter = TradeFilter.all;

  TradeFilter get currentFilter => _currentFilter;

  @override
  FutureOr<List<TradeEntity>> build() async {
    _repository = ref.watch(tradeRepositoryProvider);
    return _fetchTrades();
  }

  Future<List<TradeEntity>> _fetchTrades() async {
    final user = ref.read(authProvider).value;
    if (user == null) return [];
    return await _repository.getTrades(user.id);
  }

  Future<void> loadTrades() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetchTrades());
  }

  Future<void> addTrade(TradeEntity trade) async {
    try {
      final newTrade = await _repository.createTrade(trade);
      if (state.hasValue) {
        state = AsyncValue.data([newTrade, ...state.value!]);
      } else {
        await loadTrades();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTrade(TradeEntity trade) async {
    try {
      final updated = await _repository.updateTrade(trade);
      if (state.hasValue) {
        final current = state.value!;
        final index = current.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          final newList = List<TradeEntity>.from(current);
          newList[index] = updated;
          state = AsyncValue.data(newList);
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTrade(int tradeId) async {
    try {
      await _repository.deleteTrade(tradeId);
      if (state.hasValue) {
        final current = state.value!;
        state = AsyncValue.data(current.where((t) => t.id != tradeId).toList());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchTrades(String query) async {
    if (query.isEmpty) {
      await loadTrades();
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authProvider).value;
      if (user == null) return [];
      return await _repository.searchTrades(user.id, query);
    });
  }

  Future<void> filterBy(TradeFilter filter) async {
    _currentFilter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authProvider).value;
      if (user == null) return [];
      return await _repository.getFilteredTrades(user.id, filter);
    });
  }
}
