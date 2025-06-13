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
  String _selectedRiceVariety = 'All';
  List<Map<String, dynamic>> _riceVarieties = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _loadRiceVarieties(),
        _loadHistoricalData(),
        _loadForecastData(),
        _loadCurrentYield(),
      ]);
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
      // Call the SARIMA forecast API
      final forecast = await _apiService.getForecastData(_selectedRiceVariety);
      if (forecast != null) {
        setState(() {
          _forecastData = forecast;
        });
      }
    } catch (e) {
      print('Error loading forecast data: $e');
    }
  }

  Future<void> _loadCurrentYield() async {
    try {
      final current = await _apiService.getCurrentYieldSummary();
      if (current != null) {
        setState(() {
          _currentYield = current;
        });
      }
    } catch (e) {
      print('Error loading current yield: $e');
    }
  }

  List<FlSpot> _getForecastSpots() {
    List<FlSpot> spots = [];
    
    if (_forecastData.isEmpty) {
      print('No forecast data available'); // Debug log
      return spots;
    }
    
    // Start forecast from the next month after the last historical data
    double startMonth = DateTime.now().month.toDouble();
    
    for (int i = 0; i < _forecastData.length; i++) {
      double xValue = startMonth + i + 1;
      if (xValue > 12) xValue -= 12; // Wrap around to next year
      
      double yValue = _forecastData[i]['predicted_yield']?.toDouble() ?? 0.0;
      
      print('Forecast spot: ($xValue, $yValue)'); // Debug log
      spots.add(FlSpot(xValue, yValue));
    }
    
    return spots;
  }

  List<FlSpot> _getHistoricalSpots() {
    List<FlSpot> spots = [];
    
    if (_historicalData.isEmpty) {
      print('No historical data available'); // Debug log
      return spots;
    }
    
    // Group data by months and calculate average yield
    Map<int, List<double>> monthlyYields = {};
    
    for (var record in _historicalData) {
      if (_selectedRiceVariety == 'All' || 
          record['rice_variety_name'] == _selectedRiceVariety) {
        
        DateTime harvestDate = DateTime.parse(record['harvest_date']);
        int monthIndex = harvestDate.month;
        double yield = record['yield_per_hectare']?.toDouble() ?? 0.0;
        
        if (!monthlyYields.containsKey(monthIndex)) {
          monthlyYields[monthIndex] = [];
        }
        monthlyYields[monthIndex]!.add(yield);
      }
    }
    
    // Calculate averages and create spots
    monthlyYields.forEach((month, yields) {
      double avgYield = yields.reduce((a, b) => a + b) / yields.length;
      print('Historical spot: ($month, $avgYield)'); // Debug log
      spots.add(FlSpot(month.toDouble(), avgYield));
    });
    
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
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
        'output': '${(data['total_output'] / 1000).toStringAsFixed(1)}k kg', // Convert to thousands
      });
    });
    
    // Sort by year and season
    periods.sort((a, b) {
      int yearCompare = a['year'].compareTo(b['year']);
      if (yearCompare != 0) return yearCompare;
      return a['season'].compareTo(b['season']);
    });
    
    return periods.take(10).toList(); // Show last 10 periods
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return '1st Harvest';
    if (month >= 6 && month <= 8) return '2nd Harvest';
    if (month >= 9 && month <= 11) return '3rd Harvest';
    return '1st Harvest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
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

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeColor.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: ThemeColor.red),
                        ),
                      ),
                    ),

                  // Current Yield Summary
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Current Yield', 
                        '${_currentYield['total_yield']?.toStringAsFixed(1) ?? "0"} kg/ha', 
                        ThemeColor.green
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Total Records', 
                        _currentYield['total_records']?.toString() ?? "0", 
                        ThemeColor.secondaryColor
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Avg Production', 
                        '${_currentYield['avg_production']?.toStringAsFixed(1) ?? "0"} kg', 
                        ThemeColor.primaryColor
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Forecast Accuracy', 
                        '${_currentYield['accuracy']?.toStringAsFixed(1) ?? "95.2"}%', 
                        ThemeColor.green
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
                                const Text(
                                  'Crop Yield Forecast',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: LineChart(
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
                                            reservedSize: 30,
                                            interval: 1,
                                            getTitlesWidget: (double value, TitleMeta meta) {
                                              const months = [
                                                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                              ];
                                              if (value.toInt() >= 1 && value.toInt() <= 12) {
                                                return Text(
                                                  months[value.toInt() - 1],
                                                  style: const TextStyle(
                                                    color: ThemeColor.grey,
                                                    fontSize: 10,
                                                  ),
                                                );
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
                                      ],
                                    ),
                                  ),
                                ),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem('Historical Data', ThemeColor.secondaryColor, false),
                                    const SizedBox(width: 20),
                                    _buildLegendItem('Forecast', ThemeColor.green, true),
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
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
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
                                                child: Text(
                                                  period['season'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: ThemeColor.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  period['year'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: ThemeColor.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  period['output'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: ThemeColor.green,
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