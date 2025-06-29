import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';

class ForecastingPage extends StatefulWidget {
  const ForecastingPage({super.key});

  @override
  State<ForecastingPage> createState() => _ForecastingPageState();
}

class _ForecastingPageState extends State<ForecastingPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _historicalData = [];
  List<Map<String, dynamic>> _forecastData = [];
  Map<String, dynamic> _currentYield = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _warningMessage = '';
  String _selectedRiceVariety = 'All';
  List<Map<String, dynamic>> _riceVarieties = [];
  Map<String, dynamic> _validationMetrics = {};
  Map<String, dynamic> _dataQuality = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _warningMessage = '';
    });

    try {
      await Future.wait([
        _loadRiceVarieties(),
        _loadHistoricalData(),
        _loadCurrentYield(),
        _loadValidationMetrics(),
        _loadDataQuality(),
      ]);
      
      // Load forecast data after other data is loaded
      await _loadForecastData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRiceVarieties() async {
    try {
      final varieties = await _apiService.getRiceVarieties();
      if (varieties != null) {
        setState(() {
          _riceVarieties = varieties;
        });
      }
    } catch (e) {
      print('Error loading rice varieties: $e');
    }
  }

  Future<void> _loadHistoricalData() async {
    try {
      final data = await _apiService.getProductionRecords();
      if (data != null) {
        setState(() {
          _historicalData = data;
        });
      }
    } catch (e) {
      print('Error loading historical data: $e');
    }
  }

  Future<void> _loadForecastData() async {
    try {
      // Call the SARIMA forecast API with variety parameter
      final response = await _apiService.get('/forecast/sarima?variety=$_selectedRiceVariety');
      
      if (response != null) {
        setState(() {
          _forecastData = List<Map<String, dynamic>>.from(response['forecast'] ?? []);
          
          // Handle warnings from backend
          if (response['warning'] != null) {
            _warningMessage = response['warning'];
          }
          
          // Update data quality from forecast response
          if (response['data_quality'] != null) {
            _dataQuality['level'] = response['data_quality'];
          }
          
          // Handle recommendations
          if (response['recommendation'] != null && _warningMessage.isEmpty) {
            _warningMessage = response['recommendation'];
          }
        });
        
        print('Loaded ${_forecastData.length} forecast periods');
      } else {
        setState(() {
          _forecastData = [];
          _warningMessage = 'Unable to generate forecast data';
        });
      }
    } catch (e) {
      print('Error loading forecast data: $e');
      setState(() {
        _forecastData = [];
        _warningMessage = 'Error generating forecast: $e';
      });
    }
  }

  Future<void> _loadCurrentYield() async {
    try {
      print('Loading current yield summary...'); 
      final current = await _apiService.get('/forecast/current-summary');
      print('Current yield response: $current'); 
      
      if (current != null) {
        setState(() {
          _currentYield = {
            'total_yield': (current['total_yield'] as num?)?.toDouble() ?? 0.0,
            'total_records': current['total_records'] ?? 0,
            'avg_production': (current['avg_production'] as num?)?.toDouble() ?? 0.0,
            'accuracy': (current['accuracy'] as num?)?.toDouble() ?? 0.0,
            'data_quality': current['data_quality'] ?? 'unknown',
            'valid_records': current['valid_records'] ?? 0,
          };
        });
        print('Current yield state updated: $_currentYield'); 
      } else {
        print('Current yield response was null, using fallback');
        // Fallback calculation remains the same
        final records = await _apiService.getProductionRecords();
        if (records != null && records.isNotEmpty) {
          double totalYield = 0.0;
          double totalProduction = 0.0;
          int validRecords = 0;
          
          for (var record in records) {
            final hectares = (record['hectares'] as num?)?.toDouble() ?? 0.0;
            final quantity = (record['quantity_harvested'] as num?)?.toDouble() ?? 0.0;
            
            if (hectares > 0 && quantity > 0) {
              final yieldPerHa = quantity / hectares;
              totalYield += yieldPerHa;
              totalProduction += quantity;
              validRecords++;
            }
          }
          
          setState(() {
            _currentYield = {
              'total_yield': validRecords > 0 ? totalYield / validRecords : 0.0,
              'total_records': records.length,
              'avg_production': validRecords > 0 ? totalProduction / validRecords : 0.0,
              'accuracy': 30.0, // Low accuracy for fallback
              'data_quality': 'limited',
              'valid_records': validRecords,
            };
          });
        }
      }
    } catch (e) {
      print('Error loading current yield: $e');
      setState(() {
        _currentYield = {
          'total_yield': 0.0,
          'total_records': 0,
          'avg_production': 0.0,
          'accuracy': 0.0,
          'data_quality': 'error',
          'valid_records': 0,
        };
      });
    }
  }

  Future<void> _loadValidationMetrics() async {
    try {
      final metrics = await _apiService.get('/forecast/validate');
      if (metrics != null && metrics['error'] == null) {
        setState(() {
          _validationMetrics = metrics;
        });
        print('Loaded validation metrics: $_validationMetrics');
      } else {
        print('Validation metrics not available: ${metrics?['error']}');
        setState(() {
          _validationMetrics = {};
        });
      }
    } catch (e) {
      print('Error loading validation metrics: $e');
      setState(() {
        _validationMetrics = {};
      });
    }
  }

  Future<void> _loadDataQuality() async {
    try {
      final quality = await _apiService.get('/forecast/data-quality');
      if (quality != null) {
        setState(() {
          _dataQuality = quality;
        });
        print('Loaded data quality: $_dataQuality');
      }
    } catch (e) {
      print('Error loading data quality: $e');
    }
  }

  Widget _buildDataQualityIndicator() {
    String qualityLevel = _dataQuality['quality_level'] ?? _currentYield['data_quality'] ?? 'unknown';
    int totalRecords = _currentYield['total_records'] ?? 0;
    int validRecords = _currentYield['valid_records'] ?? 0;
    double completeness = _dataQuality['data_completeness'] ?? 0.0;
    
    Color qualityColor;
    IconData qualityIcon;
    String qualityText;
    
    switch (qualityLevel.toLowerCase()) {
      case 'excellent':
        qualityColor = ThemeColor.green;
        qualityIcon = Icons.check_circle;
        qualityText = 'Excellent';
        break;
      case 'good':
        qualityColor = ThemeColor.primaryColor;
        qualityIcon = Icons.thumb_up;
        qualityText = 'Good';
        break;
      case 'fair':
      case 'medium':
        qualityColor = Colors.orange;
        qualityIcon = Icons.warning;
        qualityText = 'Fair';
        break;
      case 'poor':
      case 'low':
        qualityColor = ThemeColor.red;
        qualityIcon = Icons.error;
        qualityText = 'Poor';
        break;
      case 'insufficient':
      case 'no_data':
        qualityColor = ThemeColor.red;
        qualityIcon = Icons.error_outline;
        qualityText = 'Insufficient';
        break;
      default:
        qualityColor = ThemeColor.grey;
        qualityIcon = Icons.help;
        qualityText = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: qualityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: qualityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(qualityIcon, color: qualityColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Data Quality: $qualityText',
                style: TextStyle(
                  color: qualityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '$validRecords/$totalRecords records',
                style: TextStyle(color: qualityColor, fontSize: 12),
              ),
            ],
          ),
          if (completeness > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Completeness: ${completeness.toStringAsFixed(1)}%',
                  style: TextStyle(color: qualityColor, fontSize: 12),
                ),
                const SizedBox(width: 16),
                if (_dataQuality['date_range_years'] != null)
                  Text(
                    'Span: ${(_dataQuality['date_range_years'] as num).toStringAsFixed(1)} years',
                    style: TextStyle(color: qualityColor, fontSize: 12),
                  ),
              ],
            ),
          ],
          if (_dataQuality['recommendations'] != null && (_dataQuality['recommendations'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            ...(_dataQuality['recommendations'] as List).take(2).map((rec) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 14, color: qualityColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rec.toString(),
                      style: TextStyle(color: qualityColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  // Widget _buildValidationMetrics() {
  //   if (_validationMetrics.isEmpty) return const SizedBox.shrink();
    
  //   double accuracy = (_validationMetrics['accuracy_percentage'] as num?)?.toDouble() ?? 0.0;
  //   double mae = (_validationMetrics['mae'] as num?)?.toDouble() ?? 0.0;
  //   double rmse = (_validationMetrics['rmse'] as num?)?.toDouble() ?? 0.0;
  //   int folds = _validationMetrics['cross_validation_folds'] ?? 0;
  //   int samples = _validationMetrics['total_samples'] ?? 0;
    
  //   Color accuracyColor = accuracy >= 80 
  //       ? ThemeColor.green 
  //       : accuracy >= 60 
  //         ? Colors.orange 
  //         : ThemeColor.red;
    
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: ThemeColor.white,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: ThemeColor.grey.withOpacity(0.3)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.analytics, color: ThemeColor.primaryColor, size: 20),
  //             const SizedBox(width: 8),
  //             const Text(
  //               'Forecast Validation Metrics',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: ThemeColor.primaryColor,
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildMetricItem(
  //                 'Accuracy',
  //                 '${accuracy.toStringAsFixed(1)}%',
  //                 accuracyColor,
  //                 Icons.verified,
  //               ),
  //             ),
  //             Expanded(
  //               child: _buildMetricItem(
  //                 'MAE',
  //                 mae.toStringAsFixed(2),
  //                 ThemeColor.secondaryColor,
  //                 Icons.show_chart,
  //               ),
  //             ),
  //             Expanded(
  //               child: _buildMetricItem(
  //                 'RMSE',
  //                 rmse.toStringAsFixed(2),
  //                 ThemeColor.secondaryColor,
  //                 Icons.timeline,
  //               ),
  //             ),
  //             Expanded(
  //               child: _buildMetricItem(
  //                 'CV Folds',
  //                 folds.toString(),
  //                 ThemeColor.secondaryColor, // Changed from ThemeColor.grey
  //                 Icons.layers,
  //               ),
  //             ),
  //           ],
  //         ),
  //         if (_validationMetrics['confidence_interval'] != null) ...[
  //           const SizedBox(height: 8),
  //           Row(
  //             children: [
  //               Icon(Icons.trending_up, size: 14, color: ThemeColor.secondaryColor), // Changed from grey
  //               const SizedBox(width: 4),
  //               Text(
  //                 'Confidence Interval: ${(_validationMetrics['confidence_interval'][0]).toStringAsFixed(1)}% - ${(_validationMetrics['confidence_interval'][1]).toStringAsFixed(1)}%',
  //                 style: const TextStyle(fontSize: 12, color: ThemeColor.secondaryColor), // Changed from grey
  //               ),
  //               const SizedBox(width: 16),
  //               Icon(Icons.dataset, size: 14, color: ThemeColor.secondaryColor), // Changed from grey
  //               const SizedBox(width: 4),
  //               Text(
  //                 'Sample Size: $samples',
  //                 style: const TextStyle(fontSize: 12, color: ThemeColor.secondaryColor), // Changed from grey
  //               ),
  //             ],
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMetricItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: ThemeColor.secondaryColor, // Changed from ThemeColor.grey
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getForecastSpots() {
    List<FlSpot> spots = [];
    
    if (_forecastData.isEmpty) {
      print('No forecast data available');
      return spots;
    }
    
    print('Forecast data: $_forecastData');
    
    // Create spots for seasonal forecasts
    for (int i = 0; i < _forecastData.length; i++) {
      // Position forecast seasons after historical data
      // Use positions 13, 14, 15 to clearly separate from historical monthly data (1-12)
      double xValue = 13.0 + i;
      
      double yValue = (_forecastData[i]['predicted_yield'] as num?)?.toDouble() ?? 0.0;
      
      if (yValue > 0) {
        print('Adding forecast spot: ($xValue, $yValue)');
        spots.add(FlSpot(xValue, yValue));
      }
    }
    
    return spots;
  }

  List<FlSpot> _getConfidenceSpots(bool isUpper) {
    List<FlSpot> spots = [];
    
    if (_forecastData.isEmpty) return spots;
    
    for (int i = 0; i < _forecastData.length; i++) {
      double xValue = 13.0 + i;
      
      double yValue = isUpper 
          ? (_forecastData[i]['confidence_upper'] as num?)?.toDouble() ?? 0.0
          : (_forecastData[i]['confidence_lower'] as num?)?.toDouble() ?? 0.0;
      
      if (yValue > 0) {
        spots.add(FlSpot(xValue, yValue));
      }
    }
    
    return spots;
  }

  List<FlSpot> _getHistoricalSpots() {
    List<FlSpot> spots = [];
    
    if (_historicalData.isEmpty) {
      print('No historical data available');
      return spots;
    }
    
    print('Historical data count: ${_historicalData.length}');
    
    // Group data by harvest seasons and calculate averages
    Map<String, List<double>> seasonalYields = {};
    
    for (var record in _historicalData) {
      if (_selectedRiceVariety == 'All' || 
          record['rice_variety_name'] == _selectedRiceVariety) {
        
        try {
          DateTime harvestDate = DateTime.parse(record['harvest_date']);
          String seasonKey = _getSeasonKey(harvestDate);
          
          // Calculate yield
          double yield = 0.0;
          if (record['yield_per_hectare'] != null) {
            yield = (record['yield_per_hectare'] as num).toDouble();
          } else if (record['actual_yield_per_hectare'] != null) {
            yield = (record['actual_yield_per_hectare'] as num).toDouble();
          } else if (record['hectares'] != null && record['quantity_harvested'] != null) {
            final hectares = (record['hectares'] as num).toDouble();
            final quantity = (record['quantity_harvested'] as num).toDouble();
            if (hectares > 0) {
              yield = quantity / hectares;
            }
          }
          
          if (yield > 0) {
            if (!seasonalYields.containsKey(seasonKey)) {
              seasonalYields[seasonKey] = [];
            }
            seasonalYields[seasonKey]!.add(yield);
          }
        } catch (e) {
          print('Error parsing date for record: $record, error: $e');
        }
      }
    }
    
    // Sort seasons chronologically and create spots
    List<String> sortedSeasons = seasonalYields.keys.toList()..sort();
    
    // Limit to last 12 seasons for better display
    int maxSeasons = 12;
    int startIndex = sortedSeasons.length > maxSeasons ? sortedSeasons.length - maxSeasons : 0;
    
    for (int i = startIndex; i < sortedSeasons.length; i++) {
      String seasonKey = sortedSeasons[i];
      List<double> yields = seasonalYields[seasonKey]!;
      double avgYield = yields.reduce((a, b) => a + b) / yields.length;
      
      // Use positions 1-12 for historical data
      double xValue = (i - startIndex + 1).toDouble();
      spots.add(FlSpot(xValue, avgYield));
    }
    
    return spots;
  }

  String _getSeasonKey(DateTime date) {
    int month = date.month;
    int year = date.year;
    
    if (month >= 3 && month <= 5) {
      return '$year-S1';
    } else if (month >= 6 && month <= 8) {
      return '$year-S2';
    } else if (month >= 9 && month <= 11) {
      return '$year-S3';
    } else {
      if (month == 12) {
        return '${year + 1}-S1';
      } else {
        return '$year-S1';
      }
    }
  }

  List<Map<String, dynamic>> _getTimePeriodsData() {
    List<Map<String, dynamic>> periods = [];
    
    // Group historical data by year and season
    Map<String, Map<String, dynamic>> yearlyData = {};
    
    for (var record in _historicalData) {
      if (_selectedRiceVariety == 'All' || 
          record['rice_variety_name'] == _selectedRiceVariety) {
        
        DateTime harvestDate = DateTime.parse(record['harvest_date']);
        String year = harvestDate.year.toString();
        String season = _getSeason(harvestDate.month);
        String key = '$season $year';
        
        if (!yearlyData.containsKey(key)) {
          yearlyData[key] = {
            'season': season,
            'year': year,
            'total_output': 0.0,
            'count': 0,
          };
        }
        
        yearlyData[key]!['total_output'] += record['quantity_harvested']?.toDouble() ?? 0.0;
        yearlyData[key]!['count']++;
      }
    }
    
    // Convert to list and format
    yearlyData.forEach((key, data) {
      periods.add({
        'season': data['season'],
        'year': data['year'],
        'output': '${(data['total_output'] / 1000).toStringAsFixed(1)}k kg',
      });
    });
    
    // Add forecast data to periods
    for (var forecast in _forecastData) {
      periods.add({
        'season': forecast['season'] ?? '',
        'year': (forecast['year'] ?? DateTime.now().year).toString(),
        'output': '${((forecast['predicted_yield'] ?? 0) * 100 / 1000).toStringAsFixed(1)}k kg (forecast)',
      });
    }
    
    // Sort by year and season
    periods.sort((a, b) {
      int yearCompare = a['year'].compareTo(b['year']);
      if (yearCompare != 0) return yearCompare;
      return a['season'].compareTo(b['season']);
    });
    
    return periods.take(15).toList(); // Show last 15 periods including forecasts
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return '1st Harvest';
    if (month >= 6 && month <= 8) return '2nd Harvest';
    if (month >= 9 && month <= 11) return '3rd Harvest';
    return '1st Harvest';
  }

  @override
  Widget build(BuildContext context) {
    // Get dynamic accuracy for display
    double dynamicAccuracy = (_currentYield['accuracy'] as num?)?.toDouble() ?? 0.0;
    
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Text(
                        'Crop Yield Forecasting',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          // Rice Variety Filter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: ThemeColor.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedRiceVariety,
                              underline: const SizedBox(),
                              items: [
                                const DropdownMenuItem(
                                  value: 'All',
                                  child: Text('All Varieties'),
                                ),
                                ..._riceVarieties.map((variety) => DropdownMenuItem(
                                  value: variety['variety_name'],
                                  child: Text(variety['variety_name']),
                                )),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRiceVariety = value;
                                  });
                                  _loadData();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Data Quality Indicator
                  _buildDataQualityIndicator(),

                  // Error/Warning Messages
                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColor.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: ThemeColor.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: ThemeColor.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_warningMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _warningMessage,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Validation Metrics (only show if available and accurate)

                  // Current Yield Summary
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Current Yield', 
                        '${(_currentYield['total_yield']?.toDouble() ?? 0.0).toStringAsFixed(1)} kg/ha', 
                        ThemeColor.green
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Total Records', 
                        (_currentYield['total_records']?.toString() ?? "0"), 
                        ThemeColor.secondaryColor
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Avg Production', 
                        '${(_currentYield['avg_production']?.toDouble() ?? 0.0).toStringAsFixed(1)} kg', 
                        ThemeColor.primaryColor
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Forecast Accuracy', 
                        '${dynamicAccuracy.toStringAsFixed(1)}%', 
                        dynamicAccuracy >= 80 
                            ? ThemeColor.green 
                            : dynamicAccuracy >= 60 
                              ? Colors.orange 
                              : ThemeColor.red
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Main Content
                  Expanded(
                    child: Row(
                      children: [
                        // Chart Section
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ThemeColor.white2,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColor.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Crop Yield Forecast',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.primaryColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_forecastData.isNotEmpty && _forecastData[0]['method'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: ThemeColor.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _forecastData[0]['method'].toString().toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: _forecastData.isEmpty && _getHistoricalSpots().isEmpty
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.insert_chart_outlined,
                                                size: 64,
                                                color: ThemeColor.grey,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'No forecast data available',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: ThemeColor.grey,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Add more production records to generate forecasts',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ThemeColor.grey,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      : LineChart(
                                          LineChartData(
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: true,
                                              drawHorizontalLine: true,
                                              getDrawingHorizontalLine: (value) {
                                                return FlLine(
                                                  color: ThemeColor.grey.withOpacity(0.3),
                                                  strokeWidth: 1,
                                                );
                                              },
                                              getDrawingVerticalLine: (value) {
                                                return FlLine(
                                                  color: ThemeColor.grey.withOpacity(0.3),
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 50,
                                                  interval: 1,
                                                  getTitlesWidget: (double value, TitleMeta meta) {
                                                    // Historical seasons (1-12)
                                                    if (value >= 1 && value <= 12) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: Text(
                                                          'H${value.toInt()}',
                                                          style: const TextStyle(
                                                            color: ThemeColor.grey,
                                                            fontSize: 9,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      );
                                                    }
                                                    // Forecast seasons (13-15)
                                                                                                        // Around line 1010, replace the forecast label section with:
                                                    else if (value >= 13 && value <= 15) {
                                                      int forecastIndex = (value - 13).toInt();
                                                      if (forecastIndex < _forecastData.length) {
                                                        String season = _forecastData[forecastIndex]['season'] ?? '';
                                                        int year = _forecastData[forecastIndex]['year'] ?? DateTime.now().year;
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white, // White background
                                                              borderRadius: BorderRadius.circular(4),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withOpacity(0.1),
                                                                  blurRadius: 2,
                                                                  offset: const Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Text(
                                                              '$year\n$season',
                                                              style: const TextStyle(
                                                                color: ThemeColor.green,
                                                                fontSize: 9,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    return const Text('');
                                                  },
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                  getTitlesWidget: (double value, TitleMeta meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: const TextStyle(
                                                        color: ThemeColor.grey,
                                                        fontSize: 10,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(
                                                color: ThemeColor.grey.withOpacity(0.3),
                                              ),
                                            ),
                                            lineBarsData: [
                                              // Historical Data Line
                                              if (_getHistoricalSpots().isNotEmpty)
                                                LineChartBarData(
                                                  spots: _getHistoricalSpots(),
                                                  isCurved: true,
                                                  color: ThemeColor.secondaryColor,
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) {
                                                      return FlDotCirclePainter(
                                                        radius: 4,
                                                        color: ThemeColor.secondaryColor,
                                                        strokeWidth: 2,
                                                        strokeColor: ThemeColor.white,
                                                      );
                                                    },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: ThemeColor.secondaryColor.withOpacity(0.1),
                                                  ),
                                                ),
                                              // Forecast Data Line
                                              if (_getForecastSpots().isNotEmpty)
                                                LineChartBarData(
                                                  spots: _getForecastSpots(),
                                                  isCurved: true,
                                                  color: ThemeColor.green,
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dashArray: [5, 5], // Dashed line for forecast
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) {
                                                      return FlDotCirclePainter(
                                                        radius: 4,
                                                        color: ThemeColor.green,
                                                        strokeWidth: 2,
                                                        strokeColor: ThemeColor.white,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              // Confidence intervals (upper bound)
                                              if (_getConfidenceSpots(true).isNotEmpty)
                                                LineChartBarData(
                                                  spots: _getConfidenceSpots(true),
                                                  isCurved: true,
                                                  color: ThemeColor.white.withOpacity(0.3),
                                                  barWidth: 1,
                                                  dotData: FlDotData(show: false),
                                                  dashArray: [2, 4],
                                                ),
                                              // Confidence intervals (lower bound)
                                              if (_getConfidenceSpots(false).isNotEmpty)
                                                LineChartBarData(
                                                  spots: _getConfidenceSpots(false),
                                                  isCurved: true,
                                                  color: ThemeColor.white.withOpacity(0.3),
                                                  barWidth: 1,
                                                  dotData: FlDotData(show: false),
                                                  dashArray: [2, 4],
                                                ),
                                            ],
                                          ),
                                        ),
                                ),
                                // Legend
                                if (_getHistoricalSpots().isNotEmpty || _getForecastSpots().isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_getHistoricalSpots().isNotEmpty)
                                        _buildLegendItem('Historical Data', ThemeColor.secondaryColor, false),
                                      if (_getHistoricalSpots().isNotEmpty && _getForecastSpots().isNotEmpty)
                                        const SizedBox(width: 20),
                                      if (_getForecastSpots().isNotEmpty)
                                        _buildLegendItem('Forecast', ThemeColor.green, true),
                                      if (_getConfidenceSpots(true).isNotEmpty)
                                        const SizedBox(width: 20),
                                      if (_getConfidenceSpots(true).isNotEmpty)
                                        _buildLegendItem('95% Confidence', ThemeColor.green.withOpacity(0.5), true),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Time Period Section
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ThemeColor.white2,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColor.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time Period',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ThemeColor.secondaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'SEASON',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'YEAR',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'OUTPUT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Table Content
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ThemeColor.secondaryColor.withOpacity(0.2),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _getTimePeriodsData().length,
                                      itemBuilder: (context, index) {
                                        final period = _getTimePeriodsData()[index];
                                        final isForecast = period['output'].toString().contains('forecast');
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isForecast 
                                                ? ThemeColor.green.withOpacity(0.05)
                                                : index % 2 == 0
                                                    ? ThemeColor.white
                                                    : ThemeColor.white2.withOpacity(0.5),
                                            border: index < _getTimePeriodsData().length - 1
                                                ? Border(
                                                    bottom: BorderSide(
                                                      color: ThemeColor.grey.withOpacity(0.2),
                                                      width: 0.5,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    if (isForecast)
                                                      Icon(
                                                        Icons.trending_up,
                                                        size: 12,
                                                        color: ThemeColor.green,
                                                      ),
                                                    if (isForecast) const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        period['season'],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isForecast 
                                                              ? ThemeColor.green 
                                                              : ThemeColor.primaryColor,
                                                          fontWeight: isForecast 
                                                              ? FontWeight.bold 
                                                              : FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  period['year'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isForecast 
                                                        ? ThemeColor.green 
                                                        : ThemeColor.primaryColor,
                                                    fontWeight: isForecast 
                                                        ? FontWeight.bold 
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  period['output'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: isForecast 
                                                        ? ThemeColor.green 
                                                        : ThemeColor.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeColor.white2,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColor.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed 
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ThemeColor.primaryColor,
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 