#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import Quick
import Nimble
import ReactiveCocoa
import ReactiveSwift
import AppKit

final class NSCollectionViewSpec: QuickSpec {
	override func spec() {
		var collectionView: TestCollectionView!

		beforeEach {
			collectionView = TestCollectionView()
		}

		describe("reloadData") {
			var bindingSignal: Signal<(), Never>!
			var bindingObserver: Signal<(), Never>.Observer!

			var reloadDataCount = 0

			beforeEach {
				let (signal, observer) = Signal<(), Never>.pipe()
				(bindingSignal, bindingObserver) = (signal, observer)

				reloadDataCount = 0

				collectionView.reloadDataSignal.observeValues {
					reloadDataCount += 1
				}
			}

			it("invokes reloadData whenever the bound signal sends a value") {
				collectionView.reactive.reloadData <~ bindingSignal

				bindingObserver.send(value: ())
				bindingObserver.send(value: ())

				expect(reloadDataCount) == 2
			}
		}
	}
}

private final class TestCollectionView: NSCollectionView {
	let reloadDataSignal: Signal<(), Never>
	private let reloadDataObserver: Signal<(), Never>.Observer

	override init(frame: CGRect) {
		(reloadDataSignal, reloadDataObserver) = Signal.pipe()
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		(reloadDataSignal, reloadDataObserver) = Signal.pipe()
		super.init(coder: aDecoder)
	}

	override func reloadData() {
		super.reloadData()
		reloadDataObserver.send(value: ())
	}
}
#endif
