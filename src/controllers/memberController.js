const Member = require('../models/Member');

// Controller for member-related operations
const memberController = {
  // Get all members
  getAllMembers: (req, res) => {
    try {
      const members = Member.findAll();
      res.json(members);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get member by ID
  getMemberById: (req, res) => {
    try {
      const member = Member.findById(req.params.id);
      if (!member) {
        return res.status(404).json({ message: 'Member not found' });
      }
      res.json(member);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Create new member
  createMember: (req, res) => {
    try {
      const { name, email, role } = req.body;
      const id = Date.now().toString();
      const member = new Member(id, name, email, role);
      const savedMember = member.save();
      res.status(201).json(savedMember);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = memberController;
