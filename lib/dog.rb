class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id
            self.update
          else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
          end
          self
    end

    def self.create(att)
        dog = Dog.new(name: att[:name], breed: att[:breed])
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(name: row[1], breed: row[2], id: row[0])
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        self.new_from_db(result)
    end

    def self.find_or_create_by(att)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", att[:name], att[:breed])
        if !dog.empty?
          data = dog[0]
          dog = Dog.new(id: data[0], name: data[1], breed: data[2])
        else
          dog = Dog.create(att)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        self.new_from_db(result)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end