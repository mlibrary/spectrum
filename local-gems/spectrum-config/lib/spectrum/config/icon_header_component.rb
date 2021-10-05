module Spectrum
  module Config
    class IconHeaderComponent < HeaderComponent
      type 'icon'

      ICON_MAP = {
        'book' => 'book',
        'article' => 'document',
        'review' => 'document',
        'book_chapter' => 'document',
        'web_resource' => 'web',
        'patent' => 'document',
        'newspaper_article' => 'document',
        'journal' => 'collection_bookmark',
        'conference_proceeding' => 'document',
        'text_resource' => 'document',
        'reference_entry' => 'document',
        'image' => 'photo',
        'report' => 'document',
        'dissertation' => 'book',
        'video' => 'play_circle',
        'scores' => 'music_note',
        'audios' => 'volume_up',
        'government_documents' => 'document',
        'datasets' => 'insert_drive_file',
        'archival_material_manuscripts' => 'archive',
        'Archival Material' => 'archive',
        'Archive' => 'archive',
        'Art' => 'photo',
        'Article' => 'document',
        'Audio' => 'volume_up',
        'Audio (music)' => 'volume_up',
        'Audio (spoken word)' => 'volume_up',
        'Audio CD' => 'volume_up',
        'Audio LP' => 'volume_up',
        'Biography' => 'book',
        'Blogs and Blog Posts' => 'web',
        'Book' => 'book',
        'Book Chapter' => 'document',
        'CDROM' => 'music_note',
        'Conference' => 'book',
        'Data File' => 'insert_drive_file',
        'Database' => 'insert_drive_file',
        'Dictionaries' => 'collection_bookmark',
        'Directories' => 'collection_bookmark',
        'Dissertation' => 'book',
        'eBook' => 'book',
        'Electronic Resource' => 'web',
        'Encyclopedias' => 'book',
        'Events and Exhibits' => 'web',
        'Government Document' => '',
        'Image' => 'photo_library',
        'Journal' => 'collection_bookmark',
        'Journal Article' => 'document',
        'Magazine Article' => 'document',
        'Manuscript' => 'document',
        'Map' => 'map',
        'Maps-Atlas' => 'map',
        'Microform' => 'theaters',
        'Mixed Material' => 'filter',
        'Motion Picture' => 'theaters',
        'Music' => 'music_note',
        'Musical Score' => 'music_note',
        'Newsletter' => 'document',
        'Newspaper' => 'newspaper',
        'Newspaper Article' => 'document',
        'Online Journal' => 'collection_bookmark',
        'Painting' => 'photo_library',
        'Photograph' => 'photo_library',
        'Photographs & Pictorial Works' => 'photo_library',
        'Poem' => 'document',
        'Publication' => 'document',
        'Research Guides' => 'web',
        'Serial' => 'collection_bookmark',
        'Software' => 'code',
        'Statistics' => 'timeline',
        'Staff Directory / People' => 'web',
        'Streaming Audio' => 'volume_up',
        'Streaming Video' => 'play_circle',
        'Trade Publication Article' => 'document',
        'Unknown' => '',
        'Video (Blu-ray)' => 'play_circle',
        'Video (DVD)' => 'play_circle',
        'Video (VHS)' => 'play_circle',
        'Video Games' => 'videogame_asset',
        'Video Recording' => 'play_circle',
        'Visual Material' => 'remove_red_eye',
        'Website' => 'web',
        'Web Resource' => 'web',
        'outbound_link_graphic' => 'outbound_link_graphic',
      }

      def initialize(region, config)
        self.region = region
      end

      def transform_item(item)
        item
      end

      def transform_icon(item)
        ICON_MAP[item]
      end

      def get_description(data)
        [data].flatten(1).map do |item|
          item = item.to_s
          if item.empty?
            nil
          else
            ret = {}
            item = transform_item(item)
            icon = transform_icon(item)
            ret[:text] = item if item
            ret[:icon] = icon if icon
            if ret.empty?
              nil
            else
             ret
            end
          end
        end.compact
      end

    end
  end
end
