## Split and Recovery System Desing

#### Activity Diagram
```mermaid
sequenceDiagram
    
    %% Split
    user ->> d_1: split
    d_1 ->> d_1: split_password(pass)
    d_1 ->> d_1_db: save share_1

    d_1 ->> server: distribute({for_device: d_2, share: share_2})
    d_2 ->>+ server: find_shares(d_2)
    server -->>- d_2: response: share_2
    d_2 ->> d_2_db: save share_2

    d_1 ->> server: distribute({for_device: d_3, share: share_3})
    d_3 ->>+ server: find_shares(d_3)
    server -->>- d_3: response: share_3
    d_3 ->> d_3_db: save share_3


    %% Recover
    user ->> d_1: recover
    d_1 ->> server: claim_for_password_recovery({consumer: d_1, provider: d_2})
    d_1 ->> server: claim_for_password_recovery({consumer: d_1, provider: d_3})
    
    d_2 ->> server: find_password_recovery_claims({for: d_2}) (scheduler)
    server -->> d_2 : response: (a claim for share_2)
    d_2 ->> d_2_db: get share_2 by meta_pass_id
    d_2 ->> server: distribute({for: d_1, type: recover, share: share_2})

    d_1 ->> server: find_shares({for: d_1}) (scheduler)
    server ->>+ d_1: response: provide share_2
    d_1 ->> d_1: if type: recover
    d_1 ->> d_1_db: find password in the local db by meta_pass_id
    d_1 ->> d_1: recover from shares[share_1, share_2]
    d_1 ->>- user: show password
