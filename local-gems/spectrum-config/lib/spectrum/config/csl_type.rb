module Spectrum
  module Config
    class CSLType < CSLBase
      DEFAULT = 'article'
      MAP = Hash.new(DEFAULT).merge(
        'Article'                   => 'article',
        'Archival Material'         => 'article',
        'Archive'                   => 'article',
        'Audio Recording'           => 'article',
        'Clothing'                  => 'article',
        'Furnishing'                => 'article',
        'Serial'                    => 'article',
        'Government Document'       => 'article',
        'Journal / eJournal'        => 'article',
        'Journal'                   => 'article',
        'Magazine'                  => 'article',
        'Market Research'           => 'article',
        'Model'                     => 'article',
        'Microform'                 => 'article',
        'Mixed Material'            => 'article',
        'Publication'               => 'article',
        'Publication Article'       => 'article',
        'Reference'                 => 'article',
        'Spoken Word Recoding'      => 'article',
        'Audio (spoken word)'       => 'article',
        'Standard'                  => 'article',
        'Unknown'                   => 'article',
        'Trade Publication Article' => 'article',
        'Transcript'                => 'article',
        'Artifact'                  => 'article',
        'Reference Entry'           => 'article',

        'Magazine Article'    => 'article-magazine',
        'Newspaper Article'   => 'article-newspaper',
        'Journal Article'     => 'article-journal',

        'bill' => 'bill',

        'Biography'     => 'book',
        'Book / eBook'  => 'book',
        'Book'          => 'book',
        'Dictionaries'  => 'book',
        'Directories'   => 'book',
        'Encyclopedias' => 'book',

        'broadcast'    => 'broadcast',

        'Book Chapter' => 'chapter',

        'CDROM'          => 'dataset',
        'Computer File'  => 'dataset',
        'Data File'      => 'dataset',
        'Data Set'       => 'dataset',
        'Software'       => 'dataset',
        'Statistics'     => 'dataset',
        'Dataset'        => 'dataset',

        'entry'              => 'entry',
        'entry-dictionary'   => 'entry-dictionary',
        'entry-encyclopedia' => 'entry-encyclopedia',
        'figure'             => 'figure',

        'Image'                           => 'graphic',
        'Photographs and Pictorial Works' => 'graphic',
        'Photograph'                      => 'graphic',
        'Drawing'                         => 'graphic',
        'Painting'                        => 'graphic',
        'Graphic Arts'                    => 'graphic',
        'Visual Material'                 => 'graphic',

        'interview'   => 'interview',
        'legislation' => 'legislation',

        'Case' => 'legal_case',

        'Manuscript' => 'manuscript',
        'Newsletter' => 'manuscript',
        'Newspaper'  => 'manuscript',
        'Play'       => 'manuscript',
        'Poem'       => 'manuscript',
        'Postcard'   => 'manuscript',
        'Archival Material Manuscript' => 'manuscript',

        'Atlas'     => 'map',
        'Map'       => 'map',
        'Map-Atlas' => 'map',

        'Video Recording' => 'motion_picture',
        'Video (Blu-ray)' => 'motion_picture',
        'Video (DVD)'     => 'motion_picture',
        'Video (VHS)'     => 'motion_picture',
        'Video Games'     => 'motion_picture',

        'Sheet Music'     => 'musical_score',
        'Music Score'     => 'musical_score',
        'Musical Score'   => 'musical_score',

        'Pamphlet' => 'pamphlet',

        'Conference'            => 'paper-conference',
        'Conference Proceeding' => 'paper-conference',
        'Paper'                 => 'paper-conference',

        'Patent' => 'patent',

        'Audio CD'        => 'song',
        'Audio LP'        => 'song',
        'Streaming Audio' => 'song',
        'Music Recording' => 'song',
        'Audio'           => 'song',
        'Music'           => 'song',
        'Audio (music)'   => 'song',

        'Motion Picture'  => 'motion_picture',
        'Streaming Video' => 'motion_picture',
        'Video Game'      => 'motion_picture',
        'Video'           => 'motion_picture',

        'post'        => 'post',
        'post-weblog' => 'post-weblog',

        'Personal Narrative' => 'personal_communication',

        'Report'           => 'report',
        'Technical Report' => 'report',

        'review' => 'review',

        'Book Review' => 'review-book',
        'Review'      => 'review-book',

        'Presentation' => 'speech',

        'Dissertation'   => 'thesis',
        'Student Thesis' => 'thesis',

        'treaty' => 'treaty',

        'Electronic Resource' => 'webpage',
        'Finding Aid'         => 'webpage',
        'Web Resource'        => 'webpage',
        'Text Resource'       => 'misc',
        'Newsletter Article'  => 'misc',
      )
      def value(data)
        if data && data[:value]
          {
            id => MAP[[data[:value]].flatten.first]
          }
        else
          { id => DEFAULT }
        end
      end
    end
  end
end
