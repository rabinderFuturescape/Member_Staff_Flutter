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

import '../models/dues_report_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
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
  List<String> _buildings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  int _totalPages = 1;

  // Filters
  String? _selectedBuilding;
  DateTime? _selectedMonth;
  String? _selectedStatus;
  String _searchQuery = '';

  final List<String> _statusOptions = ['All', 'Unpaid', 'Partial', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _loadDuesReport();
    _loadBuildings();

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
      _selectedMonth = null;
      _selectedStatus = null;
      _searchQuery = '';
      _searchController.clear();
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
          _buildFilters(),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
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
          const Divider(),
        ],
      ),
    );
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
