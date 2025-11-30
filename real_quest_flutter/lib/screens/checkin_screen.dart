import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:real_quest/services/supabase_service.dart';
import 'package:real_quest/widgets/card_widget.dart';
import 'package:real_quest/models/card.dart';
import 'package:real_quest/providers.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  bool _isLoading = false;
  String _statusMessage = '現在地周辺の施設を検索するには\nチェックインボタンを押してください';
  GameCard? _obtainedCard;

  Future<void> _handleCheckIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '位置情報を取得中...';
      _obtainedCard = null;
    });

    try {
      // 1. Request Location Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('位置情報の権限が拒否されました');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('位置情報の権限が永久に拒否されています。設定から許可してください。');
      }

      // 2. Get Current Position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _statusMessage = 'サーバーと通信中...';
      });

      // 3. Call Supabase Edge Function
      // TODO: Replace with actual user ID from Auth
      const userId = 'mock-user-id'; 
      // TODO: Implement facility detection logic or pass raw coordinates
      // For now, we pass a mock facility ID or let the backend handle it based on coords
      
      final result = await ref.read(supabaseServiceProvider).checkin(
        facilityId: '00000000-0000-0000-0000-000000000001', // Default facility for prototype
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 4. Handle Result
      // 4. Handle Result
      if (result['cards'] != null) {
        final cardsData = result['cards'] as List;
        if (cardsData.isNotEmpty) {
           // Merge template data if needed, but for now assume Edge Function returns joined data
           // or we construct it.
           // Note: GameCard.fromJson handles the structure returned by Supabase join
           final newCard = GameCard.fromJson(cardsData.first);
           
           setState(() {
             _obtainedCard = newCard;
             _statusMessage = 'チェックイン成功！\nカードを獲得しました！';
           });
           
           // Update Quest Progress
           final userId = ref.read(userIdProvider);
           if (userId != null) {
             await ref.read(questServiceProvider).updateProgress(userId, 'checkin');
             ref.refresh(userQuestsProvider); // Refresh UI
           }
        } else {
          setState(() {
            _statusMessage = 'チェックイン成功！\n(カード獲得なし)';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'チェックイン成功！\n(カード獲得なし)';
        });
      }

    } catch (e) {
      setState(() {
        _statusMessage = 'エラーが発生しました:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('チェックイン')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_obtainedCard != null) ...[
                const Text(
                  'NEW CARD!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: CardWidget(card: _obtainedCard!),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const Icon(Icons.map, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
              ],
              
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _handleCheckIn,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('現在地でチェックイン'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
