import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:math' as math;

import '../models/dues_report_model.dart';
import '../models/dues_chart_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/dues_chart_widget.dart';
import '../utils/constants.dart';
import '../utils/snackbar_helper.dart';

class AllDuesReportScreen extends StatefulWidget {
  static const routeName = '/all-dues-report';

  const AllDuesReportScreen({Key? key}) : super(key: key);

  @override
  _AllDuesReportScreenState createState() => _AllDuesReportScreenState();
}

class _AllDuesReportScreenState extends State<AllDuesReportScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<DuesReportItem> _duesReportItems = [];
  List<DuesChartItem> _chartData = [];
  List<String> _buildings = [];
  List<String> _floors = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingChart = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  int _totalPages = 1;

  // Filters
  String? _selectedBuilding;
  String? _selectedWing;
  String? _selectedFloor;
  DateTime? _selectedMonth;
  String? _selectedStatus;
  String _searchQuery = '';
  double _minDueAmount = 0;
  double _maxDueAmount = 100000;
  RangeValues _dueAmountRange = const RangeValues(0, 100000);
  String _selectedChartType = 'wing'; // 'wing', 'floor', 'top_members'

  final List<String> _statusOptions = ['All', 'Unpaid', 'Partial', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _loadDuesReport();
    _loadBuildings();
    _loadFloors();
    _loadChartData();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoadingMore &&
          _hasMoreData) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    try {
      // This would typically be an API call to get the list of buildings
      // For now, we'll use a dummy list
      setState(() {
        _buildings = ['Building A', 'Building B', 'Building C'];
      });
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
          context, 'Failed to load buildings: ${e.toString()}');
    }
  }

  Future<void> _loadFloors() async {
    try {
      // This would typically be an API call to get the list of floors
      // For now, we'll use a dummy list
      setState(() {
        _floors = ['1', '2', '3', '4', '5'];
      });
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(
          context, 'Failed to load floors: ${e.toString()}');
    }
  }

  Future<void> _loadDuesReport({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });
    }

    if (!_hasMoreData) return;

    setState(() {
      _isLoading = _currentPage == 1;
      _isLoadingMore = _currentPage > 1;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        SnackbarHelper.showErrorSnackBar(context, 'You are not logged in');
        return;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': _currentPage,
        'per_page': 15,
      };

      if (_selectedBuilding != null && _selectedBuilding != 'All') {
        queryParams['building'] = _selectedBuilding;
      }

      if (_selectedWing != null && _selectedWing != 'All') {
        queryParams['wing'] = _selectedWing;
      }

      if (_selectedFloor != null && _selectedFloor != 'All') {
        queryParams['floor'] = _selectedFloor;
      }

      if (_selectedMonth != null) {
        queryParams['month'] =
            DateFormat('yyyy-MM').format(_selectedMonth!);
      }

      if (_selectedStatus != null && _selectedStatus != 'All') {
        queryParams['status'] = _selectedStatus!.toLowerCase();
      }

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      // Add due amount range filters
      if (_minDueAmount > 0) {
        queryParams['min_due'] = _minDueAmount.toInt().toString();
      }

      if (_maxDueAmount < 100000) {
        queryParams['max_due'] = _maxDueAmount.toInt().toString();
      }

      final response = await _apiService.get(
        '/committee/dues-report',
        queryParameters: queryParams,
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'];
        final int total = data['total'];
        final int lastPage = data['last_page'];

        List<DuesReportItem> duesItems = items
            .map((item) => DuesReportItem.fromJson(item))
            .toList();

        setState(() {
          if (refresh || _currentPage == 1) {
            _duesReportItems = duesItems;
          } else {
            _duesReportItems.addAll(duesItems);
          }
          _totalPages = lastPage;
          _hasMoreData = _currentPage < lastPage;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        throw Exception('Failed to load dues report');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      SnackbarHelper.showErrorSnackBar(
          context, 'Failed to load dues report: ${e.toString()}');
    }
  }

  Future<void> _loadMoreData() async {
    if (_hasMoreData && !_isLoadingMore) {
      setState(() {
        _currentPage++;
      });
      await _loadDuesReport();
    }
  }

  Future<void> _refreshData() async {
    await _loadDuesReport(refresh: true);
    await _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoadingChart = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        SnackbarHelper.showErrorSnackBar(context, 'You are not logged in');
        return;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'chart_type': _selectedChartType,
      };

      if (_selectedMonth != null) {
        queryParams['month'] =
            DateFormat('yyyy-MM').format(_selectedMonth!);
      }

      final response = await _apiService.get(
        '/committee/dues-report/chart-summary',
        queryParameters: queryParams,
        token: token,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<DuesChartItem> chartItems = data
            .map((item) => DuesChartItem.fromJson(item))
            .toList();

        setState(() {
          _chartData = chartItems;
          _isLoadingChart = false;
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      setState(() {
        _isLoadingChart = false;
      });
      SnackbarHelper.showErrorSnackBar(
          context, 'Failed to load chart data: ${e.toString()}');
    }
  }

  Future<void> _exportCsv() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        SnackbarHelper.showErrorSnackBar(context, 'You are not logged in');
        return;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        SnackbarHelper.showErrorSnackBar(
            context, 'Storage permission is required to download the report');
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                const Text('Downloading report...'),
              ],
            ),
          );
        },
      );

      // Build query parameters
      Map<String, dynamic> queryParams = {};

      if (_selectedBuilding != null && _selectedBuilding != 'All') {
        queryParams['building'] = _selectedBuilding;
      }

      if (_selectedWing != null && _selectedWing != 'All') {
        queryParams['wing'] = _selectedWing;
      }

      if (_selectedFloor != null && _selectedFloor != 'All') {
        queryParams['floor'] = _selectedFloor;
      }

      if (_selectedMonth != null) {
        queryParams['month'] =
            DateFormat('yyyy-MM').format(_selectedMonth!);
      }

      if (_selectedStatus != null && _selectedStatus != 'All') {
        queryParams['status'] = _selectedStatus!.toLowerCase();
      }

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      // Add due amount range filters
      if (_minDueAmount > 0) {
        queryParams['min_due'] = _minDueAmount.toInt().toString();
      }

      if (_maxDueAmount < 100000) {
        queryParams['max_due'] = _maxDueAmount.toInt().toString();
      }

      // Get the download directory
      final directory = await getExternalStorageDirectory();
      final filePath =
          '${directory!.path}/dues_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      // Download the file
      await _apiService.download(
        '/committee/dues-report/export',
        filePath,
        queryParameters: queryParams,
        token: token,
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success message
      SnackbarHelper.showSuccessSnackBar(
          context, 'Report downloaded successfully');

      // Open the file
      OpenFile.open(filePath);
    } catch (e) {
      // Close the loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      SnackbarHelper.showErrorSnackBar(
          context, 'Failed to download report: ${e.toString()}');
    }
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _refreshData();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedBuilding = null;
      _selectedWing = null;
      _selectedFloor = null;
      _selectedMonth = null;
      _selectedStatus = null;
      _searchQuery = '';
      _searchController.clear();
      _minDueAmount = 0;
      _maxDueAmount = 100000;
      _dueAmountRange = const RangeValues(0, 100000);
    });
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'All Dues Report'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildAdvancedFilters(),
          _buildChartSection(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: SpinKitCircle(color: Theme.of(context).primaryColor),
                  )
                : _duesReportItems.isEmpty
                    ? const Center(
                        child: Text('No dues found'),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _duesReportItems.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _duesReportItems.length) {
                              return _buildLoadingIndicator();
                            }
                            return _buildDuesItem(_duesReportItems[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportCsv,
        tooltip: 'Export CSV',
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by member name or unit',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    _refreshData();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _refreshData();
        },
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return ExpansionTile(
      title: const Text('Advanced Filters'),
      initiallyExpanded: false,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // First row: Building and Wing
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Building',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: _selectedBuilding,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Buildings'),
                        ),
                        ..._buildings.map((building) {
                          return DropdownMenuItem<String>(
                            value: building,
                            child: Text(building),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBuilding = value;
                        });
                        _refreshData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Wing',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: _selectedWing,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Wings'),
                        ),
                        ..._buildings.map((wing) {
                          return DropdownMenuItem<String>(
                            value: wing,
                            child: Text(wing),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedWing = value;
                        });
                        _refreshData();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Second row: Floor and Month
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: _selectedFloor,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Floors'),
                        ),
                        ..._floors.map((floor) {
                          return DropdownMenuItem<String>(
                            value: floor,
                            child: Text(floor),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFloor = value;
                        });
                        _refreshData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: InkWell(
                      onTap: _selectMonth,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedMonth == null
                                  ? 'All Months'
                                  : DateFormat('MMM yyyy').format(_selectedMonth!),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Third row: Status and Amount Range
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: _selectedStatus,
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status == 'All' ? null : status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _refreshData();
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Fourth row: Amount Range Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Due Amount Range:'),
                        Text(
                          '₹${_dueAmountRange.start.toInt()} - ₹${_dueAmountRange.end.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  RangeSlider(
                    values: _dueAmountRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    labels: RangeLabels(
                      '₹${_dueAmountRange.start.toInt()}',
                      '₹${_dueAmountRange.end.toInt()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _dueAmountRange = values;
                      });
                    },
                    onChangeEnd: (RangeValues values) {
                      setState(() {
                        _minDueAmount = values.start;
                        _maxDueAmount = values.end;
                      });
                      _refreshData();
                    },
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return ExpansionTile(
      title: const Text('Dues Summary Charts'),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Chart type selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('By Wing'),
                    selected: _selectedChartType == 'wing',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChartType = 'wing';
                        });
                        _loadChartData();
                      }
                    },
                  ),
                  const SizedBox(width: 8.0),
                  ChoiceChip(
                    label: const Text('By Floor'),
                    selected: _selectedChartType == 'floor',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChartType = 'floor';
                        });
                        _loadChartData();
                      }
                    },
                  ),
                  const SizedBox(width: 8.0),
                  ChoiceChip(
                    label: const Text('Top Members'),
                    selected: _selectedChartType == 'top_members',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChartType = 'top_members';
                        });
                        _loadChartData();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Chart widget
              _isLoadingChart
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: SpinKitCircle(color: Theme.of(context).primaryColor),
                      ),
                    )
                  : _chartData.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text('No chart data available'),
                          ),
                        )
                      : _selectedChartType == 'wing' && _chartData.length <= 5
                          ? DuesPieChartWidget(
                              chartData: _chartData,
                              chartTitle: 'Total Outstanding Dues by Wing',
                            )
                          : DuesChartWidget(
                              chartData: _chartData,
                              chartTitle: _getChartTitle(),
                              chartType: _selectedChartType,
                            ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  String _getChartTitle() {
    switch (_selectedChartType) {
      case 'wing':
        return 'Total Outstanding Dues by Wing';
      case 'floor':
        return 'Total Outstanding Dues by Floor';
      case 'top_members':
        return 'Top Members with Highest Dues';
      default:
        return 'Dues Summary';
    }
  }

  Widget _buildDuesItem(DuesReportItem item) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _getStatusText(item),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.home, size: 16),
                const SizedBox(width: 4.0),
                Text('${item.unitNumber} (${item.buildingName})'),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4.0),
                Text(item.billCycle),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bill Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      currencyFormat.format(item.billAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Paid',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      currencyFormat.format(item.amountPaid),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      currencyFormat.format(item.dueAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(item.dueDate),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.dueDate.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      item.lastPaymentDate == null
                          ? 'No payment'
                          : DateFormat('dd MMM yyyy').format(item.lastPaymentDate!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Color _getStatusColor(DuesReportItem item) {
    if (item.dueDate.isBefore(DateTime.now()) && item.dueAmount > 0) {
      return Colors.red;
    } else if (item.amountPaid > 0 && item.amountPaid < item.billAmount) {
      return Colors.orange;
    } else if (item.amountPaid == 0) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText(DuesReportItem item) {
    if (item.dueDate.isBefore(DateTime.now()) && item.dueAmount > 0) {
      return 'Overdue';
    } else if (item.amountPaid > 0 && item.amountPaid < item.billAmount) {
      return 'Partial';
    } else if (item.amountPaid == 0) {
      return 'Unpaid';
    } else {
      return 'Paid';
    }
  }
}
