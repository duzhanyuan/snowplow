# Copyright (c) 2012 SnowPlow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author::    Alex Dean (mailto:alex@snowplowanalytics.com)
# Copyright:: Copyright (c) 2012 SnowPlow Analytics Ltd
# License::   Apache License Version 2.0

require 'aws/s3'

# Ruby module to support the two S3-related actions required by
# the daily ETL job:
# 1. Uploading the daily-etl.q HiveQL query to S3
# 2. Archiving the CloudFront log files by moving them into a separate bucket
module S3Utils

  # Uploads the Hive query to S3 ready to be executed as part of the Hive job.
  # Ensures we are executing the most recent version of the Hive query.
  # Parameters:
  # +config+:: the hash of configuration options
  def S3Utils.upload_etl_tools(config)

    puts "Starting the upload..."

   # Connect to S3
    AWS::S3::Base.establish_connection!(
      :access_key_id     => config[:aws][:access_key_id],
      :secret_access_key => config[:aws][:secret_access_key]
    )

    # Upload the two query files and the serde
    # Array of files to upload: "tuple" format is [Filename, Local filepath, S3 bucket path, Content type]
    [[config[:daily_query_file], config[:daily_query_path], config[:buckets][:query], 'text/plain'],
     [config[:datespan_query_file], config[:datespan_query_path], config[:buckets][:query], 'text/plain'],
     [config[:serde_file], config[:serde_path], config[:buckets][:serde], 'application/java-archive']
    ].each do |f|
      AWS::S3::S3Object.store(f[0], open(f[1]), f[2], :content_type => f[3])
      puts "Uploading %s" % f[0]
    end

  end

  # Moves (archives) the processed CloudFront logs to an archive bucket.
  # Prevents the same log files from being processed again the next day.
  # Parameters:
  # +config+:: the hash of configuration options
  def S3Utils.archive_logs(config)
    # TODO: implement
    puts "Archiving CloudFront logs..."
  end
end
