import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

/// Service for capturing and uploading photos for attendance records
class PhotoUploader {
  final ImagePicker _imagePicker;
  final Dio _dio;
  final AuthService _authService;
  final String _baseUrl;
  
  PhotoUploader({
    ImagePicker? imagePicker,
    Dio? dio,
    AuthService? authService,
    String baseUrl = 'https://api.oneapp.in',
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _dio = dio ?? Dio(),
       _authService = authService ?? AuthService(),
       _baseUrl = baseUrl;
  
  /// Capture a photo using the device camera and upload it to the server
  /// Returns the URL of the uploaded photo
  Future<String?> captureAndUploadPhoto() async {
    try {
      // Capture image using image_picker
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image == null) {
        return null;
      }
      
      // Upload the image
      return await _uploadImage(File(image.path));
    } catch (e) {
      debugPrint('Error capturing and uploading photo: $e');
      return null;
    }
  }
  
  /// Upload an image file to the server
  /// Returns the URL of the uploaded image
  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Get auth token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Get member info for context
      final member = await _authService.getCurrentMember();
      
      // Create form data for upload
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'member_id': member.id,
        'unit_id': member.unitId,
      });
      
      // Set up headers
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );
      
      // Make the request
      final response = await _dio.post(
        '$_baseUrl/api/upload-photo',
        data: formData,
        options: options,
      );
      
      // Check response
      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
  
  /// Select an image from the gallery and upload it to the server
  /// Returns the URL of the uploaded image
  Future<String?> selectAndUploadPhoto() async {
    try {
      // Select image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image == null) {
        return null;
      }
      
      // Upload the image
      return await _uploadImage(File(image.path));
    } catch (e) {
      debugPrint('Error selecting and uploading photo: $e');
      return null;
    }
  }
}
