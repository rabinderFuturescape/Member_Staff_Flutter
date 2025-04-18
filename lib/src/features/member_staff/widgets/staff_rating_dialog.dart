import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../providers/staff_rating_provider.dart';
import '../models/staff.dart';

class StaffRatingDialog extends StatefulWidget {
  final Staff staff;
  final String staffType; // 'society' or 'member'

  const StaffRatingDialog({
    Key? key,
    required this.staff,
    required this.staffType,
  }) : super(key: key);

  @override
  _StaffRatingDialogState createState() => _StaffRatingDialogState();
}

class _StaffRatingDialogState extends State<StaffRatingDialog> {
  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Rate ${widget.staff.name}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.staff.photoUrl != null
                ? NetworkImage(widget.staff.photoUrl!)
                : null,
            child: widget.staff.photoUrl == null
                ? Text(
                    widget.staff.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 30),
                  )
                : null,
          ),
          SizedBox(height: 15),
          Text(
            widget.staff.category ?? widget.staffType.capitalize(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              hintText: 'Add your feedback (optional)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final ratingProvider =
          Provider.of<StaffRatingProvider>(context, listen: false);

      await ratingProvider.submitRating(
        staffId: widget.staff.id,
        staffType: widget.staffType,
        rating: _rating.toInt(),
        feedback: _feedbackController.text,
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
