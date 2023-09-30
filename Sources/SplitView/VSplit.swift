//
//  VSplit.swift
//  SplitView
//
//  Created by Steven Harris on 3/3/23.
//

import SwiftUI

public struct VSplit<P: View, D: View, S: View>: View {
    private let isResizing: Bool
    private let fraction: FractionHolder
    private let hide: SideHolder
    private let styling: SplitStyling
    private let constraints: SplitConstraints
    private let onDrag: ((CGFloat) -> Void)?
    private let primary: P
    private let splitter: D
    private let secondary: S

    public var body: some View {
        Split(
            isResizing: isResizing,
            primary: { primary },
            secondary: { secondary }
        )
        .layout(LayoutHolder(.vertical))
        .styling(styling)
        .constraints(constraints)
        .onDrag(onDrag)
        .splitter {
            splitter
                .environmentObject(styling)
        }
        .fraction(fraction)
        .hide(hide)
    }

    public init(
        isResizing: Bool = true,
        @ViewBuilder top: @escaping () -> P,
        @ViewBuilder bottom: @escaping () -> S
    ) where D == Splitter {
        let fraction = FractionHolder()
        let hide = SideHolder()
        let styling = SplitStyling()
        let constraints = SplitConstraints()
        self.init(isResizing: isResizing,
                  fraction: fraction,
                  hide: hide,
                  styling: styling,
                  constraints: constraints,
                  onDrag: nil,
                  primary: { top() },
                  splitter: { D() },
                  secondary: { bottom() })
    }

    private init(
        isResizing: Bool,
        fraction: FractionHolder,
        hide: SideHolder,
        styling: SplitStyling,
        constraints: SplitConstraints,
        onDrag: ((CGFloat) -> Void)?,
        @ViewBuilder primary: @escaping () -> P,
        @ViewBuilder splitter: @escaping () -> D,
        @ViewBuilder secondary: @escaping () -> S
    ) {
        self.isResizing = isResizing
        self.fraction = fraction
        self.hide = hide
        self.styling = styling
        self.constraints = constraints
        self.onDrag = onDrag
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
    }

    // MARK: Modifiers

    // Note: Modifiers return a new VSplit instance with the same state except for what is
    // being modified.

    /// Return a new VSplit with the `splitter` set to a new type.
    ///
    /// If the splitter is a SplitDivider, get its `visibleThickness` and set that in `styling` before returning.
    public func splitter<T>(@ViewBuilder _ splitter: @escaping () -> T) -> VSplit<P, T, S> where T: View {
        let newSplitter = splitter()
        if let splitDivider = newSplitter as? (any SplitDivider) {
            styling.visibleThickness = splitDivider.visibleThickness
        }
        return VSplit<P, T, S>(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: {
                primary
            },
            splitter: splitter,
            secondary: { secondary }
        )
    }

    /// Return a new instance of VSplit with `constraints` set to these values.
    public func constraints(minPFraction: CGFloat? = nil, minSFraction: CGFloat? = nil, priority: SplitSide? = nil, dragToHideP: Bool = false, dragToHideS: Bool = false) -> VSplit {
        let constraints = SplitConstraints(
            minPFraction: minPFraction,
            minSFraction: minSFraction,
            priority: priority,
            dragToHideP: dragToHideP,
            dragToHideS: dragToHideS
        )
        return VSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of VSplit with `onDrag` set to `callback`.
    ///
    /// The `callback` will be executed as `splitter` is dragged, with the current value of `privateFraction`.
    /// Note that `fraction` is different. It is only set when drag ends, and it is used to determine the initial fraction at open.
    public func onDrag(_ callback: ((CGFloat) -> Void)?) -> VSplit {
        return VSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: callback,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    ///  Return a new instance of VSplit with `styling` set to these values.
    public func styling(color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil, hideSplitter: Bool = false) -> VSplit {
        let styling = SplitStyling(color: color, inset: inset, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness, hideSplitter: hideSplitter)
        return VSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of VSplit with `fraction` set to this FractionHolder
    public func fraction(_ fraction: FractionHolder) -> VSplit<P, D, S> {
        VSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of VSplit with `fraction` set to a FractionHolder holding onto this CGFloat
    public func fraction(_ fraction: CGFloat) -> VSplit<P, D, S> {
        self.fraction(FractionHolder(fraction))
    }

    /// Return a new instance of VSplit with `hide` set to this SideHolder
    public func hide(_ side: SideHolder) -> VSplit<P, D, S> {
        VSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: side,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of VSplit with `hide` set to a SideHolder holding onto this SplitSide
    public func hide(_ side: SplitSide) -> VSplit<P, D, S> {
        hide(SideHolder(side))
    }
}

struct VSplit_Previews: PreviewProvider {
    static var previews: some View {
        VSplit(
            top: { Color.green },
            bottom: {
                HSplit(
                    left: { Color.red },
                    right: {
                        VSplit(
                            top: { Color.blue },
                            bottom: { Color.yellow }
                        )
                    }
                )
            }
        )

        VSplit(
            top: {
                HSplit(left: { Color.red }, right: { Color.green })
            },
            bottom: {
                HSplit(left: { Color.yellow }, right: { Color.blue })
            }
        )
    }
}
