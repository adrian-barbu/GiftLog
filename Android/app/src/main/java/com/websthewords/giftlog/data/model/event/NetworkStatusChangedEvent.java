package com.websthewords.giftlog.data.model.event;

/**
 * @description     Network Status Changed Event
 *
 * @author
 */

public class NetworkStatusChangedEvent {
    int status = 1;

    public NetworkStatusChangedEvent(int status) {
        this.status = status;
    }

    public int getStatus() { return status; }
}
