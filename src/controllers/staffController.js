const Staff = require('../models/Staff');

// Controller for staff-related operations
const staffController = {
  // Get all staff
  getAllStaff: (req, res) => {
    try {
      const staffMembers = Staff.findAll();
      res.json(staffMembers);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get staff by ID
  getStaffById: (req, res) => {
    try {
      const staffMember = Staff.findById(req.params.id);
      if (!staffMember) {
        return res.status(404).json({ message: 'Staff member not found' });
      }
      res.json(staffMember);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Create new staff
  createStaff: (req, res) => {
    try {
      const { name, email, department, position } = req.body;
      const id = Date.now().toString();
      const staffMember = new Staff(id, name, email, department, position);
      const savedStaff = staffMember.save();
      res.status(201).json(savedStaff);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = staffController;
