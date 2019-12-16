import UIKit

final class FlickrPhotosViewController: UICollectionViewController {
  // MARK: - Properties
  private let reuseIdentifier = "FlickrCell"
  private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  private var searches = [FlickrSearchResults]()
  private let flickr = Flickr()
  private let itemsPerRow: CGFloat = 3
}

// MARK: - Private
private extension FlickrPhotosViewController {
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
}

// MARK: - UITextFieldDelegate
extension FlickrPhotosViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    textField.addSubview(activityIndicator)
    activityIndicator.frame = textField.bounds
    activityIndicator.startAnimating()
    
    flickr.searchFlickr(for: textField.text!) { searchResults in
      activityIndicator.removeFromSuperview()
      
      switch searchResults {
      case .error(let error) :
        print("Error Searching: \(error)")
      case .results(let results):
        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
        self.searches.insert(results, at: 0)
        self.collectionView?.reloadData()
      }
    }
    
    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - UICollectionViewDataSource
extension FlickrPhotosViewController {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return searches.count
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath) as! FlickrPhotoCell
    let flickrPhoto = photo(for: indexPath)
    cell.backgroundColor = UIColor.white
    cell.imageView.image = flickrPhoto.thumbnail
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    // 1
    switch kind {
    // 2
    case UICollectionView.elementKindSectionHeader:
      // 3
      guard
        let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: "\(FlickrPhotoHeaderView.self)",
          for: indexPath) as? FlickrPhotoHeaderView
        else {
          fatalError("Invalid view type")
      }

      let searchTerm = searches[indexPath.section].searchTerm
      headerView.label.text = searchTerm
      return headerView
    default:
      // 4
      assert(false, "Invalid element type")
    }
  }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
