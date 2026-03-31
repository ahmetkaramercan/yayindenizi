import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../../features/cities/data/models/city_model.dart';
import '../../../features/cities/data/models/district_model.dart';
import '../../../features/cities/presentation/providers/cities_provider.dart';

/// Searchable city and district selector for registration forms.
/// District selection is enabled only after a city is selected.
class CityDistrictSelector extends ConsumerStatefulWidget {
  final String? selectedCityId;
  final String? selectedDistrictId;
  final String? selectedCityName;
  final String? selectedDistrictName;
  final ValueChanged<CityModel?> onCitySelected;
  final ValueChanged<DistrictModel?> onDistrictSelected;

  const CityDistrictSelector({
    super.key,
    this.selectedCityId,
    this.selectedDistrictId,
    this.selectedCityName,
    this.selectedDistrictName,
    required this.onCitySelected,
    required this.onDistrictSelected,
  });

  @override
  ConsumerState<CityDistrictSelector> createState() => _CityDistrictSelectorState();
}

class _CityDistrictSelectorState extends ConsumerState<CityDistrictSelector> {
  Future<void> _openCityPicker() async {
    final result = await showModalBottomSheet<CityModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CitySearchSheet(
        initialSearch: widget.selectedCityName,
        onSelect: (city) => Navigator.pop(ctx, city),
      ),
    );
    if (result != null) {
      widget.onCitySelected(result);
      widget.onDistrictSelected(null);
    }
  }

  Future<void> _openDistrictPicker() async {
    if (widget.selectedCityId == null || widget.selectedCityId!.isEmpty) return;

    final result = await showModalBottomSheet<DistrictModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DistrictSearchSheet(
        cityId: widget.selectedCityId!,
        initialSearch: widget.selectedDistrictName,
        onSelect: (district) => Navigator.pop(ctx, district),
      ),
    );
    if (result != null) {
      widget.onDistrictSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SelectField(
          label: 'İl (İsteğe bağlı)',
          hint: 'İl seçin',
          value: widget.selectedCityName,
          prefixIcon: Icons.location_city_outlined,
          onTap: _openCityPicker,
        ),
        const SizedBox(height: AppConstants.paddingM),
        _SelectField(
          label: 'İlçe (İsteğe bağlı)',
          hint: widget.selectedCityId != null && widget.selectedCityId!.isNotEmpty
              ? 'İlçe seçin'
              : 'Önce il seçin',
          value: widget.selectedDistrictName,
          prefixIcon: Icons.location_on_outlined,
          onTap: widget.selectedCityId != null && widget.selectedCityId!.isNotEmpty
              ? _openDistrictPicker
              : null,
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData prefixIcon;
  final VoidCallback? onTap;

  const _SelectField({
    required this.label,
    required this.hint,
    this.value,
    required this.prefixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
        child: Text(
          value ?? '',
          style: AppTextStyles.body1.copyWith(
            color: value != null && value!.isNotEmpty
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CitySearchSheet extends ConsumerStatefulWidget {
  final String? initialSearch;
  final void Function(CityModel) onSelect;

  const _CitySearchSheet({
    this.initialSearch,
    required this.onSelect,
  });

  @override
  ConsumerState<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<_CitySearchSheet> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? '';
    _search = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider(_search.isEmpty ? null : _search));

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'İl ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: citiesAsync.when(
              data: (cities) => ListView.builder(
                itemCount: cities.length,
                itemBuilder: (_, i) {
                  final city = cities[i];
                  return ListTile(
                    title: Text(city.name),
                    onTap: () => widget.onSelect(city),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Yüklenemedi: $e', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictSearchSheet extends ConsumerStatefulWidget {
  final String cityId;
  final String? initialSearch;
  final void Function(DistrictModel) onSelect;

  const _DistrictSearchSheet({
    required this.cityId,
    this.initialSearch,
    required this.onSelect,
  });

  @override
  ConsumerState<_DistrictSearchSheet> createState() => _DistrictSearchSheetState();
}

class _DistrictSearchSheetState extends ConsumerState<_DistrictSearchSheet> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearch ?? '';
    _search = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsProvider((
      cityId: widget.cityId,
      search: _search.isEmpty ? null : _search,
    )));

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'İlçe ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: districtsAsync.when(
              data: (districts) => ListView.builder(
                itemCount: districts.length,
                itemBuilder: (_, i) {
                  final district = districts[i];
                  return ListTile(
                    title: Text(district.name),
                    onTap: () => widget.onSelect(district),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Yüklenemedi: $e', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
