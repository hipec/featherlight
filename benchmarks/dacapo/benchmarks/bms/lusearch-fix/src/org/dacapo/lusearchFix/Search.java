package org.dacapo.lusearchFix;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.FilterIndexReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.search.TopDocCollector;

public class Search {
  static final int MAX_DOCS_TO_COLLECT = 20;
  public int completed = 0;
  private int COMPLETION_GOAL;
  
  private static class OneNormsReader extends FilterIndexReader {
    private String field;
    public OneNormsReader(IndexReader in, String field) {
      super(in);
      this.field = field;
    }
    public byte[] norms(String field) throws IOException{
      return in.norms(this.field);
    }
  }
  public Search() {
    super();
  }
  public void main(String[] args) throws Exception{
    String usage = "Usage:\tjava org.dacapo.lusearchFix.Search [-index dir] [-field f] [-repeat n] [-queries file] [-raw] [-norms field] [-paging hitsPerPage]";
    usage += "\n\tSpecify \'false\' for hitsPerPage to use streaming instead of paging search.";
    if(args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
      System.out.println(usage);
      System.exit(0);
    }
    String index = "index";
    String field = "contents";
    String queryBase = null;
    int repeat = 0;
    boolean raw = false;
    String normsField = null;
    int hitsPerPage = 10;
    String outBase = null;
    int threads = 1;
    int totalQueries = 32;
    for(int i = 0; i < args.length; i++) {
      if("-index".equals(args[i])) {
        index = args[i + 1];
        i++;
      }
      else 
        if("-field".equals(args[i])) {
          field = args[i + 1];
          i++;
        }
        else 
          if("-queries".equals(args[i])) {
            queryBase = args[i + 1];
            i++;
          }
          else 
            if("-repeat".equals(args[i])) {
              repeat = Integer.parseInt(args[i + 1]);
              i++;
            }
            else 
              if("-raw".equals(args[i])) {
                raw = true;
              }
              else 
                if("-norms".equals(args[i])) {
                  normsField = args[i + 1];
                  i++;
                }
                else 
                  if("-paging".equals(args[i])) {
                    hitsPerPage = Integer.parseInt(args[i + 1]);
                    i++;
                  }
                  else 
                    if("-output".equals(args[i])) {
                      outBase = args[i + 1];
                      i++;
                    }
                    else 
                      if("-threads".equals(args[i])) {
                        threads = Integer.parseInt(args[i + 1]);
                        i++;
                      }
                      else 
                        if("-totalqueries".equals(args[i])) {
                          totalQueries = Integer.parseInt(args[i + 1]);
                          i++;
                        }
    }
    completed = 0;
    COMPLETION_GOAL = (int)(0.8D * totalQueries);
    final QueryThread[] queryThreads = new QueryThread[totalQueries];
    try {
    org.jikesrvm.scheduler.WS.allocateFinishAbort();
    try {{
      for(int j = 0; j < totalQueries; j++) {
        queryThreads[j] = new QueryThread(this, "Query" + j, j, threads, totalQueries, index, outBase, queryBase, field, normsField, raw, hitsPerPage);
        
        try {
        org.jikesrvm.scheduler.WS.setFlag();
          queryThreads[j].run();
        org.jikesrvm.scheduler.WS.join();
        } catch (org.jikesrvm.scheduler.WS.Continuation c) {
        org.jikesrvm.scheduler.RVMThread.getCurrentThread().canAbortIfRequired();
        }
      }
    }
    org.jikesrvm.scheduler.WS.finish();
    } catch(org.jikesrvm.scheduler.WS.Finish _$$f) {}
    } catch(org.jikesrvm.scheduler.WS.AbortAtFailure _aaf) {
    org.jikesrvm.scheduler.WS.wsAcceptAbortAtFailure();
    } catch(org.jikesrvm.scheduler.WS.AbortAtSuccess _aas) {
    org.jikesrvm.scheduler.WS.wsAcceptAbortAtSuccess();
    }
  }
  
  class QueryThread {
    Search parent;
    int id;
    int threadCount;
    int totalQueries;
    String name;
    String index;
    String outBase;
    String queryBase;
    String field;
    String normsField;
    boolean raw;
    int hitsPerPage;
    public QueryThread(Search parent, String name, int id, int threadCount, int totalQueries, String index, String outBase, String queryBase, String field, String normsField, boolean raw, int hitsPerPage) {
      super();
      this.parent = parent;
      this.id = id;
      this.threadCount = threadCount;
      this.totalQueries = totalQueries;
      this.name = name;
      this.index = index;
      this.outBase = outBase;
      this.queryBase = queryBase;
      this.field = field;
      this.normsField = normsField;
      this.raw = raw;
      this.hitsPerPage = hitsPerPage;
    }
    public void run(){
      try {
        new QueryProcessor(parent, name, id, index, outBase, queryBase, field, normsField, raw, hitsPerPage).run();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
  
  public class QueryProcessor {
    Search parent;
    String field;
    int hitsPerPage;
    boolean raw;
    IndexReader reader;
    Searcher searcher;
    BufferedReader in;
    PrintWriter out;
    public QueryProcessor(Search parent, String name, int id, String index, String outBase, String queryBase, String field, String normsField, boolean raw, int hitsPerPage) {
      super();
      this.parent = parent;
      this.field = field;
      this.raw = raw;
      this.hitsPerPage = hitsPerPage;
      try {
        reader = IndexReader.open(index);
        if(normsField != null) 
          reader = new OneNormsReader(reader, normsField);
        searcher = new IndexSearcher(reader);
        String query = queryBase + (id < 10 ? "00" : (id < 100 ? "0" : "")) + id + ".txt";
        in = new BufferedReader(new FileReader(query));
        out = new PrintWriter(new BufferedWriter(new FileWriter(outBase + id)));
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
    public void run() throws java.io.IOException{
      Analyzer analyzer = new StandardAnalyzer();
      QueryParser parser = new QueryParser(field, analyzer);
      while(true){
        String line = in.readLine();
        if(line == null || line.length() == -1) 
          break ;
        line = line.trim();
        if(line.length() == 0) 
          break ;
        Query query = null;
        try {
          query = parser.parse(line);
        }
        catch (org.apache.lucene.queryParser.ParseException e) {
          e.printStackTrace();
        }
        searcher.search(query, null, 10);
        doPagingSearch(query);
      }
      reader.close();
      out.flush();
      out.close();
      synchronized(parent) {
        ++parent.completed;
        if(parent.completed % 4 == 0) {
          System.out.println(parent.completed + " query batches completed");
        }
      }
      if(parent.completed >= parent.COMPLETION_GOAL) {
        System.out.println("Aborting as " + parent.completed + " completed");
        org.jikesrvm.scheduler.WS.abort();
        
      }
    }
    public void doPagingSearch(Query query) throws IOException{
      TopDocCollector collector = new TopDocCollector(MAX_DOCS_TO_COLLECT);
      searcher.search(query, collector);
      ScoreDoc[] hits = collector.topDocs().scoreDocs;
      int numTotalHits = collector.getTotalHits();
      if(numTotalHits > 0) 
        out.println(numTotalHits + " total matching documents for " + query.toString(field));
      int start = 0;
      int end = Math.min(numTotalHits, hitsPerPage);
      while(start < Math.min(MAX_DOCS_TO_COLLECT, numTotalHits)){
        end = Math.min(hits.length, start + hitsPerPage);
        for(int i = start; i < end; i++) {
          if(raw) {
            out.println("doc=" + hits[i].doc + " score=" + hits[i].score);
            continue ;
          }
          Document doc = searcher.doc(hits[i].doc);
          String path = doc.get("path");
          if(path != null) {
            out.println("\t" + (i + 1) + ". " + path);
            String title = doc.get("title");
            if(title != null) {
              out.println("   Title: " + doc.get("title"));
            }
          }
          else {
            out.println((i + 1) + ". " + "No path for this document");
          }
        }
        start = end;
      }
    }
  }
}
