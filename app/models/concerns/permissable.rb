module Permissable
  extend ActiveSupport::Concern


  PERMISSION_HASH = {
      "1" => ["brother", "sister"],
      "2" => ["mother", "father"],
      "3" => ["son", "daughter"],
      "4" => ["grandfather", "grandmother"],
      "5" => ["grandson", "granddaughter"],
      "6" => ["son_in_law", "daughter_in_law"],
      "7" => ["father_in_law", "mother_in_law"],
      "8" => ["husband", "wife"] 
    }
  attr_reader :parse_permission

  def parse(permissions_array)
    permissions_array.join(" ")
  end

  def relationships_permitted    
    PERMISSION_HASH.map { |key, value| value if permissions.include?(key) }.compact.flatten
  end

  def names_permitted
    permission_str = permissions.split(" ")
    permission_str.select {|permission| permission.match(/[A-Za-z]/)}
  end

  def all_permitted_members
    self.family.people.collect do |member|
      member.first_name if member.can_see?(self)
    end.compact.join(", ")
  end
  
  def get_people(permission_key)
    singular = ["mother", "father", "husband", "wife"]
    relations = PERMISSION_HASH[permission_key]
    relatives = relations.map do |relation|
      if singular.include?(relation)
        current_person.send(relation).id if current_person.send(relation)
      else
        current_person.send(relation.pluralize).map {|rel| rel.id}
      end
    end.compact.flatten
  end

  def get_relation(person_id)
    relation = Person.find(person_id).relationship_to(current_person)
    PERMISSION_HASH.map do |key, value|
      key if value.include?(relation)
    end.compact.first
  end
end