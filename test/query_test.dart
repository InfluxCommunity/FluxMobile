import 'package:flutter_test/flutter_test.dart';
import 'package:flux_mobile/influxDB.dart';

void main() {
  test('Single Table', () {
    List<InfluxDBTable> tables = InfluxDBQuery(api: null, queryString: '')
        .tablesFromCSVString(CSVOneTable);
    expect(tables, hasLength(1));
  });

  test('Yield Names', () {
    List<InfluxDBTable> tables = InfluxDBQuery(api: null, queryString: '')
        .tablesFromCSVString(CSVMultipleYields);
    expect(tables, hasLength(2));
    ["count", "sum"].forEach((String yn) {
      int matches = tables.where((InfluxDBTable table) {
        return table.yieldName == yn;
      }).length;
      expect(
        matches,
        1,
        reason:
            "should be exactly 1 table with yieldName $yn, but found $matches",
      );
    });
  });

  test('Multiple series for one schema', () {
    List<InfluxDBTable> tables = InfluxDBQuery(api: null, queryString: '')
        .tablesFromCSVString(CSVOneSchemaMultipleSeries);
    expect(tables, hasLength(6));
  });
}

const String CSVOneTable =
    ''',result,table,_start,_stop,_time,_value,_field,_measurement,url\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,0,2021-01-23T15:56:04.758005808Z,2021-01-23T16:06:04.758005808Z,2021-01-23T16:05:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
''';

const String CSVMultipleYields =
    ''',result,table,_start,_stop,_value,_field,_measurement\r
,count,0,2021-01-23T17:39:10.767632359Z,2021-01-23T17:44:10.767632359Z,4,n,ctr\r

,result,table,_start,_stop,_value,_field,_measurement\r
,sum,0,2021-01-23T17:39:10.767632359Z,2021-01-23T17:44:10.767632359Z,3726,n,ctr\r
''';

const String CSVOneSchemaMultipleSeries =
    ''',result,table,_start,_stop,_time,_value,_field,_measurement,url\r
,_result,0,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,0,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,0,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,0,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,0,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://us-central1-1.gcp.cloud2.influxdata.com/api/v2/query?7deab9003b58d713\r
,_result,1,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,1,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,1,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,1,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,1,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://westeurope-1.azure.cloud2.influxdata.com/api/v2/query?orgID=b0b779a83c532d69\r
,_result,2,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,2,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,2,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,2,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,2,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://eastus-1.azure.cloud2.influxdata.com/api/v2/query?orgID=1ef4aca4c431277e\r
,_result,3,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,3,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,3,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,3,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,3,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=725f1a0817d15947\r
,_result,4,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,4,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,4,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,4,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,4,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://eu-central-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=3941070f336ae986\r
,_result,5,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:10:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
,_result,5,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:11:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
,_result,5,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:12:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
,_result,5,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:13:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
,_result,5,2021-01-23T18:09:33.669035099Z,2021-01-23T18:14:33.669035099Z,2021-01-23T18:14:00Z,200,_status_code,read_result,https://us-west-2-1.aws.cloud2.influxdata.com/api/v2/query?orgID=27b1f32678fe4738\r
''';
