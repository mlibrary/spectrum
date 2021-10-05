module Spectrum
  class SpecialCollectionsBibRecord 
    def initialize(fullrecord)
      @fullrecord = fullrecord
    end
    def title
      get_field_subset(main: '245', subfields: 'abk')
    end
    def author
     process_list_of_fields([
       ['100', 'abcd'],
       ['110', 'abcd'],
       ['111', 'ancd'],
       ['130', 'aplskf'],
     ])
    end
    def genre
      get_field_subset(main: '974', subfields: 'm')
    end
    def sgenre
      ''
    end
    def date
      process_list_of_fields([
        ['260', 'c'],
        ['264', 'c'],
        ['245', 'f'],
      ])

    end
    def edition
      get_field_subset(main: '250', subfields: 'a') 
    end
    def publisher
      process_list_of_fields([
        ['260', 'b'],
        ['264', 'b'],
      ])
    end
    def place
      process_list_of_fields([
        ['260', 'a'],
        ['264', 'a'],
      ])
    end
    def extent
      get_field_subset(main: '300', subfields: 'abcf') 
    end
    
    private 
    def get_field_subset(main:,subfields:)
      (@fullrecord[main] || []).select do |subfield|
        subfields.split('').include?(subfield.code)
      end.map(&:value).join(' ')
    end
    def process_list_of_fields(array)
      array.map{|x| get_field_subset(main: x[0], subfields: x[1])}
      .reject{|y| y.empty? }
      .join(' ')

    end
  end
  class ClementsBibRecord < SpecialCollectionsBibRecord
    def author
     process_list_of_fields([
       ['100', 'abcd'],
       ['110', 'ab'],
       ['111', 'acd'],
       ['130', 'aplskf'],
     ])
    end
    def genre
      clements_genre
    end
    def sgenre
      clements_genre
    end
    private
    def clements_genre
      clements_genre_mapping[get_field_subset(main: '974', subfields: 'm')]
    end
    def clements_genre_mapping
      { 
        'BOOK' => 'Book',
        'ISSBD' => 'Book',
        'ISSUE' => 'Book',
        'SCORE' => 'Graphics',
        'OTHERVM' => 'Graphics',
        'MIXED' => 'Manuscripts',
        'ATLAS' => 'Map',
        'MAP' => 'Map'
      }
    end
  end
end
