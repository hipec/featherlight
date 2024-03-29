import java.util.PriorityQueue;
import java.util.Queue;

public class Featherlight implements Config.Benchmark {

  public Featherlight() { 
    this.solution = null;
  }

  public static void main(final String[] args) {
    Featherlight benchmark = new Featherlight();
    Config.boardInit();
    System.out.println("Args: ");
    Config.printArgs();
    Config.launch(benchmark);
  }

  protected Config.SearchBoard solution;

  public void speculativeSearch() {
    final Queue<Config.SearchBoard> queue = new PriorityQueue<Config.SearchBoard>();

    // Create root node
    queue.add(Config.initialSearchBoard);

    finish_abort { 
      speculativeSearch(queue);
    } 

    final Config.SearchBoard solutionBoard = solution;
    if (solutionBoard != null) {
      System.out.println("Num Moves to Solution ="+ solutionBoard.numMoves);
    } else {
      System.out.println("ERROR: No solution found!");
    }
    Config.validate(solution);
    solution = null;
  }

  private void speculativeSearch(final Object loopQueue) {
    final Queue<Config.SearchBoard> queue = (Queue<Config.SearchBoard>) loopQueue;
    while (!queue.isEmpty()) {
      final Config.SearchBoard loopNode = queue.poll();
      if (loopNode.isSolution()) {
        solution= loopNode;
        System.out.println("Aborting");    
        abort;
      }
      Config.processSudokuNode(queue, loopNode);
      if (!queue.isEmpty()) {
        final Queue<Config.SearchBoard>[] queues = Config.split(queue);
        for (int i=0; i<queues.length; i++) { 
          async { speculativeSearch(queues[i]); }
        }
      }
    }
  }
}
