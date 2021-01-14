class Role
  OWNER = 'owner'
  AGENT = 'agent'
  FRIEND = 'friend'
  MARKETING = 'marketing'
  HR = 'hr'
  FINANCE = 'finance'
  MANAGER = 'manager'

  def self.is_valid_team_member_role(role)
    [Role::AGENT, Role::FRIEND].include? role
  end

  def self.get_default_team_member_role()
    Role::AGENT
  end

  def self.get_role_label(role)
    map = [
        self::AGENT => "Team Member",
        self::OWNER => "Admin",
        self::FRIEND => "Fan",
        self::MARKETING => 'Marketing',
        self::HR => 'Human Resources',
        self::FINANCE => 'Finance',
        self::MANAGER => 'Manager'
    ]
    return map[0][role]
  end
end
