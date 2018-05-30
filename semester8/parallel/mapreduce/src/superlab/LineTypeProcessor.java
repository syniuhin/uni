package superlab;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.*;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

public class LineTypeProcessor {

    public static class LineTypeMapper extends MapReduceBase implements Mapper<LongWritable, Text, Text, IntWritable> {

        public LineTypeMapper() {
        }

        @Override
        public void map(LongWritable key, Text value,
                        OutputCollector<Text, IntWritable> output,
                        Reporter reporter) throws IOException {
            String line = value.toString();
            StringTokenizer s = new StringTokenizer(line, ",");
            String lineType = s.nextToken();
            output.collect(new Text(lineType), new IntWritable(1));
        }
    }

    public static class LineTypeReducer extends MapReduceBase implements Reducer<Text, IntWritable, Text, IntWritable> {

        public LineTypeReducer() {
        }

        @Override
        public void reduce(Text text, Iterator<IntWritable> iterator, OutputCollector<Text, IntWritable> outputCollector, Reporter reporter) throws IOException {
            int sum = 0;
            while (iterator.hasNext()) {
                sum += iterator.next().get();
            }
            outputCollector.collect(text, new IntWritable(sum));
        }
    }

    public static void main(String args[]) throws IOException {
        JobConf conf = new JobConf(LineTypeProcessor.class);

        conf.setJobName("line_type_processor");
        conf.setOutputKeyClass(Text.class);
        conf.setOutputValueClass(IntWritable.class);
        conf.setMapperClass(LineTypeMapper.class);
        conf.setCombinerClass(LineTypeReducer.class);
        conf.setReducerClass(LineTypeReducer.class);
        conf.setInputFormat(TextInputFormat.class);
        conf.setOutputFormat(TextOutputFormat.class);

        FileInputFormat.setInputPaths(conf, new Path(args[0]));
        FileOutputFormat.setOutputPath(conf, new Path(args[1]));

        JobClient.runJob(conf);
    }

}
