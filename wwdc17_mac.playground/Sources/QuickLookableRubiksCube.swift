public class QuickLookableRubiksCube: RubiksCube { }

extension QuickLookableRubiksCube: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let view = RubiksDemoSceneView(rubiksCube: self)
        let snapshot = view.snapshot()
        return PlaygroundQuickLook(reflecting: snapshot)
    }
}
