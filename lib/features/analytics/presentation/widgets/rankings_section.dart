import 'package:flutter/material.dart';
import '../../domain/entities/seller_ranking_entity.dart';
import '../../domain/entities/top_product_entity.dart';

/// Section rendering Top Products and Sellers Ranking in tabbed views.
class RankingsSection extends StatefulWidget {
  final List<TopProductEntity> topProducts;
  final List<SellerRankingEntity> sellersRanking;

  const RankingsSection({
    super.key,
    required this.topProducts,
    required this.sellersRanking,
  });

  @override
  State<RankingsSection> createState() => _RankingsSectionState();
}

class _RankingsSectionState extends State<RankingsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 3,
              labelColor: const Color(0xFF818CF8),
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.leaderboard_rounded, size: 18),
                  text: 'Топ товаров',
                ),
                Tab(
                  icon: Icon(Icons.people_alt_rounded, size: 18),
                  text: 'Рейтинг продавцов',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopProductsList(widget.topProducts),
                _buildSellersRankingList(widget.sellersRanking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(List<TopProductEntity> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных по продажам товаров',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(color: Color(0xFF334155), height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index < 3
                      ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                      : const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index < 3 ? const Color(0xFF818CF8) : const Color(0xFF475569),
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index < 3 ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${item.sku}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.totalRevenue.toStringAsFixed(2)} TJS',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.totalQuantitySold} шт.',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSellersRankingList(List<SellerRankingEntity> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных по продажам сотрудников',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(color: Color(0xFF334155), height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final rankMedal = index == 0
            ? '🥇'
            : index == 1
                ? '🥈'
                : index == 2
                    ? '🥉'
                    : '${index + 1}';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      rankMedal,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.sellerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.totalOrders} чеков • Премия: ${item.commissionEarned.toStringAsFixed(2)} TJS',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.totalRevenue.toStringAsFixed(2)} TJS',
                        style: const TextStyle(
                          color: Color(0xFF818CF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.revenueSharePercentage,
                          style: const TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (item.shareValue / 100.0).clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFF0F172A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
