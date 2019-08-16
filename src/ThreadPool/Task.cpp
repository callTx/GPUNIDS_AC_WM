#include "Task.h"

Task::Task(Inspection *inspection, std::shared_ptr<Packet> pkt) {
    inspection_ = inspection;
    pkt_ = pkt;
}


Task::~Task() {
}

void Task::operator()() {
  inspection_->exec(pkt_);
}

void Task::run() {
  inspection_->exec(pkt_);
}
