--!strict

export type Effect = {
    Run: (target: Model) -> (),
    Stop: (target: Model) -> ()
}

return nil