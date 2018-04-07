import hxd.Key in K;

enum ElevatorState {
  Open;
  Opening;
  Closed;
  Closing;
  Moving;
}

enum ElevatorDirection {
  Up;
  Down;
}

class Elevator {

  public var current_floor : Int;
  public var state : ElevatorState;
  public var direction : ElevatorDirection;
  public var floors : Map<Int,Array<ElevatorDirection>>;
  public var top_floor : Int;
  public var override_open : Bool;

  public function new(floors : Int, current_floor : Int = 1) {
    this.current_floor = current_floor;
    this.state = Closed;
    this.direction = null;
    this.floors = [for (f in (1...(floors + 1))) f => []];
    this.top_floor = floors;
    this.override_open = false;
  }

  public function open() {
    if (state == Closing || state == Closed) {
      override_open = true;
    }
  }

  public function call(floor : Int, dir : ElevatorDirection) {
    if (floors[floor][0] == null) {
      floors[floor][0] = dir;
    } else if (floors[floor][0] != dir) {
      floors[floor][1] = dir;
    }
  }

  public function request(floor : Int) {
    if ((floor == current_floor) && (state != Moving)) {
      open();
    }
    else if (floor == 1) {
      call(1, Up);
    }
    else if (floor == top_floor) {
      call(top_floor, Down);
    }
    else {
      if (floor > current_floor) {
        call(floor, Up);
      }
      else if (floor < current_floor) {
        call(floor, Down);
      }
      else {
        if (direction == Up) {
          call(current_floor, Down);
        }
        else if (direction == Down) {
          call(current_floor, Up);
        }
      }
    }
  }

  public function handleElevator() {
    switch (state) {

      case Open:
        if (floors[current_floor].indexOf(direction) >= 0) {
          floors[current_floor].remove(direction);
        }
        else if (current_floor == 1 || current_floor == top_floor) {
          floors[current_floor].shift();
        }
        state = Closing;

      case Opening:
        state = Open;

      case Closed:
        if (floors[current_floor].indexOf(direction) >= 0) {
          state = Opening;
          override_open = false;
        }
        else if (((current_floor == 1) || (current_floor == top_floor)) && (floors[current_floor][0] != null)) {
          state = Opening;
          override_open = false;
          if (current_floor == 1) {
            direction = Up;
          }
          else if (current_floor == top_floor) {
            direction = Down;
          }
        }
        else if (override_open) {
          state = Opening;
          override_open = false;
        }

        else if (direction != null) {
          var done = true;
          for (f in floors.keys()) {
            if (floors[f][0] != null) {
              done = false;
              break;
            }
          }
          if (done) {
            direction = null;
          }
          else {
            if (current_floor == 1 && direction == Up) {
              var found = false;
              for (f in (current_floor + 1...top_floor + 1)) {
                if (floors[f][0] != null) {
                  found = true;
                  break;
                }
              }
              if (found) {
                state = Moving;
              }
            }
            else if (current_floor == top_floor && direction == Down) {
              var found = false;
              for (f in (1...current_floor)) {
                if (floors[f][0] != null) {
                  found = true;
                  break;
                }
              }
              if (found) {
                state = Moving;
              }
            }
            else {
              if (direction == Up && current_floor != top_floor) {
                var found = false;
                for (f in (current_floor + 1...top_floor + 1)) {
                  if (floors[f][0] != null) {
                    found = true;
                    break;
                  }
                }
                if (found) {
                  state = Moving;
                }
                else {
                  direction = Down;
                }
              }
              else if (direction == Down && current_floor != 1) {
                var found = false;
                for (f in (1...current_floor)) {
                  if (floors[f][0] != null) {
                    found = true;
                    break;
                  }
                }
                if (found) {
                  state = Moving;
                }
                else {
                  direction = Up;
                }
              }
              else if (direction == Up) {
                direction = Down;
              }
              else if (direction == Down) {
                direction = Up;
              }
            }
          }
        }
        else if (direction == null) {
          if (current_floor == 1) {
            var found = false;
            for (f in (current_floor + 1...top_floor + 1)) {
              if (floors[f][0] != null) {
                found = true;
                break;
              }
            }
            if (found) {
              direction = Up;
            }
          }
          else if (current_floor == top_floor) {
            var found = false;
            for (f in (1...current_floor)) {
              if (floors[f][0] != null) {
                found = true;
                break;
              }
            }
            if (found) {
              direction = Down;
            }
          }
          else {
            if (current_floor <= (top_floor + 1)/ 2) {
              var found = false;
              for (f in (1...current_floor)) {
                if (floors[f][0] != null) {
                  found = true;
                  break;
                }
              }
              if (found) {
                direction = Down;
              }
            }
            else {
              var found = false;
              for (f in (current_floor + 1...top_floor + 1)) {
                if (floors[f][0] != null) {
                  found = true;
                  break;
                }
              }
              if (found) {
                direction = Up;
              }
            }
          }
        }

      case Closing:
        if (override_open) {
          state = Opening;
          override_open = false;
        }
        else {
          state = Closed;
        }

      case Moving:
        if (direction == Up) {
          current_floor++;
        }
        else if (direction == Down) {
          current_floor--;
        }
        if (floors[current_floor].indexOf(direction) >= 0) {
          state = Closed;
        }
        else {
          var found = false;
          if ((direction == Up) && (current_floor != top_floor)) {
            for (f in (current_floor + 1...top_floor + 1)) {
              if (floors[f][0] != null) {
                found = true;
              }
            }
          }
          else if ((direction == Down) && (current_floor != 1)) {
            for (f in (1...current_floor)) {
              if (floors[f][0] != null) {
                found = true;
              }
            }
          }
          if (!found) {
            state = Closed;
          }
        }
    }
  }
}

class Main extends hxd.App {

  var countdown : Int;
  var timer : haxe.Timer;

  var timeri : h2d.Text;
  var debug : h2d.Text;
  var debug2 : h2d.Text;
  var debug3 : h2d.Text;
  var debug4 : h2d.Text;
  var debug5 : h2d.Text;

  var elevator : Elevator;

  public function keyListener() {
    if (K.isPressed(K.E)) {
      elevator.call(3, Down);
    }
    if (K.isPressed(K.S)) {
      elevator.call(2, Down);
    }
    if (K.isPressed(K.D)) {
      elevator.call(2, Up);
    }
    if (K.isPressed(K.C)) {
      elevator.call(1, Up);
    }
    if (K.isPressed(K.O)) {
      elevator.open();
    }
    if (K.isPressed(K.U)) {
      elevator.request(3);
    }
    if (K.isPressed(K.J)) {
      elevator.request(2);
    }
    if (K.isPressed(K.M)) {
      elevator.request(1);
    }
  }

  override function init() {

    engine.backgroundColor = 0x202020;

    countdown = 3;
    timer = new haxe.Timer(1000);

    var font = hxd.res.DefaultFont.get();

    timeri = new h2d.Text(font, s2d);
    timeri.x = 5;
    timeri.y = 5;
    debug = new h2d.Text(font, s2d);
    debug.x = 5;
    debug.y = 25;
    debug2 = new h2d.Text(font, s2d);
    debug2.x = 5;
    debug2.y = 45;
    debug3 = new h2d.Text(font, s2d);
    debug3.x = 5;
    debug3.y = 65;
    debug4 = new h2d.Text(font, s2d);
    debug4.x = 5;
    debug4.y = 85;
    debug5 = new h2d.Text(font, s2d);
    debug5.x = 5;
    debug5.y = 105;

    elevator = new Elevator(3);
  }

  override function update(dt : Float) {
    keyListener();
    timer.run = function() {
      countdown--;
    }
    if (countdown <= 0) {
      elevator.handleElevator();
      countdown = 3;
    }
    timeri.text = "Next State Change: " + countdown;
    debug.text = "Elevator Current Floor: " + elevator.current_floor;
    debug2.text = "Elevator Top Floor: " + elevator.top_floor;
    debug3.text = "Elevator Floors: " + elevator.floors;
    debug4.text = "Elevator State: " + elevator.state;
    debug5.text = "Elevator Direction: " + elevator.direction;
  }

  static function main() {
	   new Main();
  }
}
