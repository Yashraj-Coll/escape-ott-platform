document.addEventListener('DOMContentLoaded', function() {
    // Store for continue watching and my list movies 
    let currentFullSectionView = null;
    let isInSectionView = false;
	
	function checkSubscriptionAndRedirect() {
	    if (!isUserSubscribed && userRole !== 'admin') {
	        showNotification('Please upgrade to a premium plan to access this feature', 'error');
	        setTimeout(() => {
	            window.location.href = 'changePlan.jsp';
	        }, 2000);
	        return false;
	    }
	    return true;
	}
	
	   
	
	// Add smooth scrolling for navbar links
	document.querySelectorAll('.navbar-nav .nav-link').forEach(link => {
	    link.addEventListener('click', function(e) {
	        e.preventDefault();
	        const targetId = this.getAttribute('href').slice(1);
	        let targetSection;
			
	        
			switch(targetId) {
			    case 'home':
			        targetSection = document.querySelector('.hero-section');
			        break;
			    case 'popularmovies':
			        targetSection = document.querySelector('section[id*="popularmovies"]');
			        break;
			    case 'popularseries':
			        targetSection = document.querySelector('section[id*="popularseries"]');
			        break;
			    case 'populartvshows':
			        targetSection = document.querySelector('section[id*="populartvshows"]');
			        break;
			}
	        
	        if (targetSection) {
	            // Account for fixed navbar height
	            const navbarHeight = document.querySelector('.navbar').offsetHeight;
	            const targetPosition = targetSection.getBoundingClientRect().top + window.pageYOffset - navbarHeight;
	            
	            window.scrollTo({
	                top: targetPosition,
	                behavior: 'smooth'
	            });
	            
	            // Update active state of nav links
	            document.querySelectorAll('.nav-link').forEach(navLink => {
	                navLink.classList.remove('active');
	            });
	            this.classList.add('active');
	        }
	    });
	});

	// Add this function at the top level
	function storeLikedMovies(likedMovies) {
	    if (!likedMovies || !Array.isArray(likedMovies)) return;
	    
	    const likeButtons = document.querySelectorAll('.like-btn');
	    likeButtons.forEach(btn => {
	        const movieCard = btn.closest('.movie-card');
	        if (movieCard) {
	            const movieId = parseInt(movieCard.dataset.movieId);
	            if (likedMovies.includes(movieId)) {
	                btn.classList.add('liked');
	                btn.querySelector('i').style.color = '#ff69b4';
	            } else {
	                btn.classList.remove('liked');
	                btn.querySelector('i').style.color = '';
	            }
	        }
	    });
	}
	// Improved Implementation
	function initializeUserData() {
	    if (!isUserAuthenticated) {
	        return;
	    }
	    
	    fetch('api/user-data')
	        .then(response => {
	            if (!response.ok) {
	                throw new Error('Failed to load user data');
	            }
	            return response.json();
	        })
	        .then(data => {
	            if (data.success && data.userData) {
	                // Update sections
	                if (data.userData.continueWatching) {
	                    updateContinueWatchingSection(data.userData.continueWatching);
	                }
	                if (data.userData.myList) {
	                    updateMyListSection(data.userData.myList);
	                }
	                if (data.userData.likedMovies) {
	                    storeLikedMovies(data.userData.likedMovies);
	                }
	            }
	        })
	        .catch(error => {
	            console.error('Error:', error);
	            // Only show notification if user is authenticated
	            if (isUserAuthenticated) {
	                showNotification('Failed to load user data. Please refresh the page.', 'error');
	            }
	        });
	}

    // Navbar scroll effect
    const navbar = document.querySelector('.navbar');
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Initialize the banner carousel
    var bannerCarouselElement = document.getElementById('bannerCarousel');
    if (bannerCarouselElement) {
        new bootstrap.Carousel(bannerCarouselElement, {
            interval: 3000,
            pause: 'hover'
        });
    }

    // Utility function for debouncing
    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

	function createMovieCard(movie, isInMyList, isInContinueWatching) {
	    if (!movie || !movie.movieId) {
	        console.error('Invalid movie data:', movie);
	        return null;
	    }

	    const card = document.createElement('div');
	    card.className = 'movie-card';
	    card.dataset.movieId = movie.movieId;
	    card.dataset.genre = movie.genre;

	    // Calculate progress for continue watching
	    let progressTime = 0;
	    let progressWidth = 0;
	    let remainingTime = '';

		if (isInContinueWatching && movie.progress && movie.duration) {
		    // Convert progress to seconds if it's in percentage
		    if (movie.progress <= 100) {
		        progressTime = (movie.progress / 100) * parseFloat(movie.duration);
		        progressWidth = movie.progress;
		    } else {
		        progressTime = parseFloat(movie.progress);
		        progressWidth = (progressTime / parseFloat(movie.duration)) * 100;
		    }

		    // Calculate remaining time
		    const timeLeft = Math.max(0, parseFloat(movie.duration) - progressTime);
		    remainingTime = formatRemainingTime(timeLeft);
		}

	    // Create initial card HTML with loading state
	    card.innerHTML = `
	        <div class="card-loading-spinner">
	            <i class="fas fa-spinner fa-spin"></i>
	        </div>`;

	    // Fetch user data and movie status
	    fetch('api/user-data')
	        .then(response => {
	            if (!response.ok) throw new Error('Network response was not ok');
	            return response.json();
	        })
	        .then(data => {
	            if (data.success && data.userData) {
	                const isLiked = data.userData.likedMovies && 
	                              data.userData.likedMovies.includes(parseInt(movie.movieId));
	                const isInList = data.userData.myList && 
	                               data.userData.myList.some(m => m.movieId === parseInt(movie.movieId));

	                let cardHTML = `
	                    <img src="${movie.posterPath}" alt="${movie.title}" class="movie-poster">
	                    ${isInContinueWatching ? `
	                        <div class="progress-bar-wrapper">
	                            <div class="progress-bar" style="width: ${Math.min(progressWidth, 100)}%;"></div>
	                        </div>
	                    ` : ''}
	                    <div class="movie-info">
	                        <h3 class="movie-title">${movie.title}</h3>
	                        <p class="movie-meta">
	                            ${movie.year || ''} ${movie.genre ? '| ' + movie.genre : ''} ${movie.duration ? '| ' + movie.duration : ''}
	                            
	                        </p>
	                        <div class="movie-buttons">
	                            <button class="btn btn-sm btn-light play-btn" 
	                                    data-video="${movie.videoPath}" 
	                                    data-movie-id="${movie.movieId}"
	                                    data-progress="${progressTime}"
	                                    data-duration="${movie.duration}">
	                                <i class="fas fa-play"></i>
	                            </button>
	                            <button class="btn btn-sm btn-outline-light toggle-mylist-btn ${isInList ? 'in-list' : ''}" 
	                                    data-in-list="${isInList}">
	                                <i class="fas ${isInList ? 'fa-minus' : 'fa-plus'}"></i>
	                            </button>
	                            <button class="btn btn-sm btn-outline-light like-btn ${isLiked ? 'liked' : ''}" 
	                                    data-liked="${isLiked}">
	                                <i class="fas fa-heart" ${isLiked ? 'style="color: #ff69b4;"' : ''}></i>
	                            </button>
	                            ${isInContinueWatching ? `
	                                <button class="btn btn-sm btn-outline-light remove-btn">
	                                    <i class="fas fa-times"></i>
	                                </button>
	                            ` : ''}
	                        </div>
	                    </div>`;

	                card.innerHTML = cardHTML;

	                // Update progress bar width after card is added to DOM
	                const progressBar = card.querySelector('.progress-bar');
	                if (progressBar) {
	                    setTimeout(() => {
	                        progressBar.style.width = `${Math.min(progressWidth, 100)}%`;
	                    }, 0);
	                }

	                addEventListeners(card);
	            }
	        })
	        .catch(error => {
	            console.error('Error fetching user data:', error);
	            // Fallback HTML with basic card structure
	            const fallbackHTML = `
	                <img src="${movie.posterPath}" alt="${movie.title}" class="movie-poster">
	                ${isInContinueWatching ? `
	                    <div class="progress-bar-wrapper">
	                        <div class="progress-bar" style="width: ${Math.min(progressWidth, 100)}%;"></div>
	                    </div>
	                ` : ''}
	                <div class="movie-info">
	                    <h3 class="movie-title">${movie.title}</h3>
	                    <p class="movie-meta">
	                        ${movie.year || ''} ${movie.genre ? '| ' + movie.genre : ''} ${movie.duration ? '| ' + movie.duration : ''}
	                        
	                    </p>
	                    <div class="movie-buttons">
	                        <button class="btn btn-sm btn-light play-btn" 
	                                data-video="${movie.videoPath}" 
	                                data-movie-id="${movie.movieId}"
	                                data-progress="${progressTime}"
	                                data-duration="${movie.duration}">
	                            <i class="fas fa-play"></i>
	                        </button>
	                        <button class="btn btn-sm btn-outline-light toggle-mylist-btn">
	                            <i class="fas fa-plus"></i>
	                        </button>
	                        <button class="btn btn-sm btn-outline-light like-btn">
	                            <i class="fas fa-heart"></i>
	                        </button>
	                    </div>
	                </div>`;
	            card.innerHTML = fallbackHTML;
	            addEventListeners(card);
	        });

	    return card;
	}

	
	function createMyListSection() {
	    let section = document.getElementById('myList');
	    if (section) {
	        section.remove();
	    }

	    // Create new section
	    section = document.createElement('section');
	    section.id = 'myList';
	    section.className = 'category-section';
	    section.innerHTML = `
	        <div class="category-header">
	            <h2 class="category-title">My List</h2>
	            <a href="#" class="see-all">See All</a>
	        </div>
	        <div class="movie-row-container">
	            <button class="nav-button prev"><i class="fas fa-chevron-left"></i></button>
	            <div class="movie-row"></div>
	            <button class="nav-button next"><i class="fas fa-chevron-right"></i></button>
	        </div>`;

			// Add the event listener right after creating the section
			   section.querySelector('.see-all').addEventListener('click', function(e) {
			       e.preventDefault();
			       showFullSectionView('myList');
			   });
			   
	    // Insert after Popular Movies section
	    const popularMoviesSection = document.getElementById('popularmovies');
	    if (popularMoviesSection) {
	        popularMoviesSection.parentNode.insertBefore(section, popularMoviesSection.nextSibling);
	    }

	    return section;
	}

	function createContinueWatchingSection() {
	    let section = document.getElementById('continueWatching');
	    if (section) {
	        section.remove();
	    }

	    // Create new section
	    section = document.createElement('section');
	    section.id = 'continueWatching';
	    section.className = 'category-section';
	    section.innerHTML = `
	        <div class="category-header">
	            <h2 class="category-title">Continue Watching</h2>
	            <a href="#" class="see-all">See All</a>
	        </div>
	        <div class="movie-row-container">
	            <button class="nav-button prev"><i class="fas fa-chevron-left"></i></button>
	            <div class="movie-row"></div>
	            <button class="nav-button next"><i class="fas fa-chevron-right"></i></button>
	        </div>`;

			// Add the event listener right after creating the section
			   section.querySelector('.see-all').addEventListener('click', function(e) {
			       e.preventDefault();
			       showFullSectionView('continueWatching');
			   });
			   
			   // Insert after Trending Now section
	    const trendingSection = document.getElementById('trendingnow');
	    if (trendingSection) {
	        trendingSection.parentNode.insertBefore(section, trendingSection.nextSibling);
	    }

	    return section;
	}
	
    // Function to get all movies from all sections
	function getAllMovies() {
	    var allMovies = [];
	    document.querySelectorAll('.movie-card').forEach(function(card) {
	        var metaParts = card.querySelector('.movie-meta').textContent.split('|');
	        allMovies.push({
	            title: card.querySelector('.movie-title').textContent,
	            genre: card.dataset.genre,
	            posterPath: card.querySelector('.movie-poster').src,
	            videoPath: card.querySelector('.play-btn').dataset.video,
	            movieId: card.dataset.movieId,
	            year: metaParts[0] ? metaParts[0].trim() : '',
	            duration: metaParts[2] ? metaParts[2].trim() : ''
	        });
	    });
	    return allMovies;
	}

	
	function filterMoviesByGenre(genre) {
	    const popularMoviesSection = document.querySelector('#popularmovies');
	    if (!popularMoviesSection) return;
	    
	    const movieRow = popularMoviesSection.querySelector('.movie-row');
	    if (!movieRow) return;
	    
	    // Store original movies from Popular Movies section if not already stored
	    if (!window.originalPopularMovies) {
	        window.originalPopularMovies = Array.from(movieRow.querySelectorAll('.movie-card'));
	    }
	    
	    // Clear current movies
	    movieRow.innerHTML = '';
	    
	    if (genre === 'All') {
	        // For 'All', restore original Popular Movies
	        window.originalPopularMovies.forEach(card => {
	            const clone = card.cloneNode(true);
	            addEventListeners(clone);
	            movieRow.appendChild(clone);
	        });
	    } else {
	        // For specific genre, get matching movies from ALL sections including Popular Movies
	        const allMovies = document.querySelectorAll('.category-section .movie-card');
	        const addedMovieIds = new Set();
	        
	        // First add matching movies from Popular Movies section to ensure they appear
	        window.originalPopularMovies.forEach(card => {
	            const movieId = card.dataset.movieId;
	            const cardGenre = card.dataset.genre;
	            
	            if (cardGenre === genre && !addedMovieIds.has(movieId)) {
	                addedMovieIds.add(movieId);
	                const clone = card.cloneNode(true);
	                addEventListeners(clone);
	                movieRow.appendChild(clone);
	            }
	        });
	        
	        // Then add matching movies from other sections
	        allMovies.forEach(card => {
	            const movieId = card.dataset.movieId;
	            const cardGenre = card.dataset.genre;
	            
	            if (cardGenre === genre && !addedMovieIds.has(movieId)) {
	                addedMovieIds.add(movieId);
	                const clone = card.cloneNode(true);
	                addEventListeners(clone);
	                movieRow.appendChild(clone);
	            }
	        });
	    }
	    
	    setupNavigation('popularmovies');
	}

	function addEventListeners(card) {
	    // Play button
	    const playBtn = card.querySelector('.play-btn');
	    if (playBtn) {
	        playBtn.onclick = (e) => {
	            e.stopPropagation();
	            if (!isUserAuthenticated) {
	                showNotification('Please sign in/sign up to continue watching', 'error');
	                setTimeout(() => {
	                    window.location.href = 'login.jsp';
	                }, 2000);
	                return;
	            }
	            if (!checkSubscriptionAndRedirect()) return;
	            showVideoPlayer(playBtn.dataset.video, card.dataset.movieId);
	        };
	    }
	    
	    // My List button
		const myListBtn = card.querySelector('.toggle-mylist-btn');
		if (myListBtn) {
		    myListBtn.onclick = (e) => {
		        e.stopPropagation();
		        if (!isUserAuthenticated) {
		            showNotification('Please sign in/sign up to add movies to your list', 'error');
		            setTimeout(() => {
		                window.location.href = 'login.jsp';
		            }, 2000);
		            return;
		        }

		        if (!isUserSubscribed && userRole !== 'admin') {
		            showNotification('Please upgrade to a premium plan to create your list', 'error');
		            setTimeout(() => {
		                window.location.href = 'changePlan.jsp';
		            }, 2000);
		            return;
		        }

	            if (myListBtn.classList.contains('in-list')) {
	                removeFromMyList(card.dataset.movieId);
	            } else {
	                addToMyList(card.dataset.movieId);
	            }
	        };
	    }
	    
	    // Like button
		const likeBtn = card.querySelector('.like-btn');
		if (likeBtn) {
		    likeBtn.onclick = (e) => {
		        e.stopPropagation();
		        if (!isUserAuthenticated) {
		            showNotification('Please sign in/sign up to like movies', 'error');
		            setTimeout(() => {
		                window.location.href = 'login.jsp';
		            }, 2000);
		            return;
		        }

		        if (!isUserSubscribed && userRole !== 'admin') {
		            showNotification('Please upgrade to a premium plan to like movies', 'error');
		            setTimeout(() => {
		                window.location.href = 'changePlan.jsp';
		            }, 2000);
		            return;
		        }
	            toggleLike(card.dataset.movieId);
	        };
	    }
	}


	// Add this at the start of your script to store original movies
	window.addEventListener('DOMContentLoaded', () => {
	    const popularMoviesRow = document.querySelector('#popularmovies .movie-row');
	    if (popularMoviesRow) {
	        window.originalPopularMovies = Array.from(popularMoviesRow.querySelectorAll('.movie-card'));
	    }
	});

	// Event listeners for genre pills
	document.querySelectorAll('.genre-pill').forEach(pill => {
	    pill.onclick = function() {
	        // Remove active class from all pills
	        const pills = this.closest('.genre-pills').querySelectorAll('.genre-pill');
	        pills.forEach(p => p.classList.remove('active'));
	        
	        // Add active class to clicked pill
	        this.classList.add('active');
	        
	        // Filter by genre
	        filterMoviesByGenre(this.textContent.trim());
	    };
	});

    // Helper Functions
	function formatTime(seconds) {
	    if (!seconds) return "00:00";
	    
	    const minutes = Math.floor(seconds / 60);
	    const remainingSeconds = Math.floor(seconds % 60);
	    
	    const minutesStr = String(minutes).padStart(2, '0');
	    const secondsStr = String(remainingSeconds).padStart(2, '0');
	    
	    return `${minutesStr}:${secondsStr}`;
	}

	function formatRemainingTime(timeInSeconds) {
	    if (!timeInSeconds || timeInSeconds <= 0) return '';
	    
	    timeInSeconds = Math.max(0, timeInSeconds); // Ensure we don't have negative time
	    
	    const hours = Math.floor(timeInSeconds / 3600);
	    const minutes = Math.floor((timeInSeconds % 3600) / 60);
	    const seconds = Math.floor(timeInSeconds % 60);
	    
	    // Format time appropriately
	    if (hours > 0) {
	        // If more than an hour left
	        return `${hours}h ${minutes}m left`;
	    } else if (minutes > 0) {
	        // If more than a minute but less than an hour left
	        if (minutes === 1) {
	            // Special case for 1 minute
	            return "1m left";
	        }
	        return `${minutes}m left`;
	    } else {
	        // If less than a minute left
	        if (seconds < 1) {
	            return "Less than 1s left";
	        }
	        return `${seconds}s left`;
	    }
	}
	   

    function showNotification(message, type = 'success') {
        const notification = document.createElement('div');
        notification.className = 'notification ' + type;
        notification.innerHTML = 
            '<i class="fas ' + (type === 'success' ? 'fa-check-circle' : 'fa-times-circle') + '" style="margin-right: 10px;"></i>' +
            message;
        document.body.appendChild(notification);

        setTimeout(function() {
            document.body.removeChild(notification);
        }, 3000);
    }

    // Function to check auth and subscription status
	function checkAuthAndSubscription() {
	    if (!isUserAuthenticated) {
	        showNotification('Please sign in/Sign up to continue watching', 'error');
	        setTimeout(() => {
	            window.location.href = 'login.jsp';
	        }, 2000);
	        return false;
	    }
	    if (!isUserSubscribed) {
	        showNotification('Please upgrade to a premium plan to access this feature', 'error');
	        setTimeout(() => {
	            window.location.href = 'changePlan.jsp';
	        }, 2000);
	        return false;
	    }
	    return true;
	}

    // Full Section View Function
    function showFullSectionView(sectionId) {
        if (!isInSectionView) {
			
			// Check authentication for Continue Watching and My List sections
			        if ((sectionId === 'continueWatching' || sectionId === 'myList') && !isUserAuthenticated) {
			            showNotification('Please sign in/sign up to view this section', 'error');
			            setTimeout(() => {
			                window.location.href = 'login.jsp';
			            }, 2000);
			            return;
			        }
			        
			        // Check subscription for My List section
			        if (sectionId === 'myList' && !isUserSubscribed && userRole !== 'admin') {
			            showNotification('Please upgrade to a premium plan to create your list', 'error');
			            setTimeout(() => {
			                window.location.href = 'changePlan.jsp';
			            }, 2000);
			            return;
			        }
					
            isInSectionView = true;
            currentFullSectionView = sectionId;

            const existingView = document.getElementById('fullSectionView');
            if (existingView) {
                existingView.remove();
            }

            const fullView = document.createElement('div');
            fullView.className = 'full-section-view';
            fullView.id = 'fullSectionView';
            fullView.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: #0f0f0f;
                z-index: 1000;
                overflow-y: auto;
                padding: 80px 20px 20px 20px;
            `;

            // Get section data
            const section = document.getElementById(sectionId);
            const sectionTitle = section.querySelector('.category-title').textContent;
            const movieCards = section.querySelectorAll('.movie-card');

            const header = document.createElement('div');
            header.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                padding: 20px;
                background-color: #0f0f0f;
                border-bottom: 1px solid #333;
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 1001;
            `;

            const titleContainer = document.createElement('div');
            titleContainer.style.cssText = `
                flex: 1;
                text-align: center;
                position: relative;
            `;

            const title = document.createElement('h1');
            title.textContent = sectionTitle;
            title.style.cssText = `
                color: #fff;
                font-size: 28px;
                font-weight: 700;
                margin: 0;
                display: inline-block;
            `;

            const closeButton = document.createElement('button');
            closeButton.innerHTML = '<i class="fas fa-times"></i>';
            closeButton.className = 'btn btn-outline-light';
            closeButton.style.cssText = `
                padding: 8px 12px;
                font-size: 18px;
                cursor: pointer;
                position: absolute;
                right: 20px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                color: #fff;
            `;

            closeButton.addEventListener('mouseover', function() {
                this.style.color = '#e50914';
            });

            closeButton.addEventListener('mouseout', function() {
                this.style.color = '#fff';
            });

            closeButton.addEventListener('click', function() {
                cleanupFullSectionView();
            });

            titleContainer.appendChild(title);
            header.appendChild(titleContainer);
            header.appendChild(closeButton);

            const movieContainer = document.createElement('div');
            movieContainer.style.cssText = `
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 20px;
                padding: 20px;
                justify-items: center;
                margin-top: 20px;
            `;

            movieCards.forEach(card => {
                const clonedCard = card.cloneNode(true);
                clonedCard.style.margin = '0';
                clonedCard.style.width = '200px';
                
                const playBtn = clonedCard.querySelector('.play-btn');
                if (playBtn) {
                    playBtn.addEventListener('click', function(e) {
                        e.stopPropagation();
                        showVideoPlayer(this.dataset.video, clonedCard.dataset.movieId);
                    });
                }

                movieContainer.appendChild(clonedCard);
            });

            fullView.appendChild(header);
            fullView.appendChild(movieContainer);
            document.body.appendChild(fullView);
            document.body.style.overflow = 'hidden';

            const style = document.createElement('style');
            style.textContent = `
                .full-section-view {
                    animation: fadeIn 0.3s ease;
                }
                
                .full-section-view .movie-card {
                    animation: scaleIn 0.3s ease;
                }
                
                @keyframes fadeIn {
                    from { opacity: 0; }
                    to { opacity: 1; }
                }
                
                @keyframes scaleIn {
                    from {
                        transform: scale(0.9);
                        opacity: 0;
                    }
                    to {
                        transform: scale(1);
                        opacity: 1;
                    }
                }
                
                .full-section-view .movie-card:hover {
                    transform: scale(1.05);
                }
            `;
            document.head.appendChild(style);
        }
    }

    function cleanupFullSectionView() {
        const fullView = document.getElementById('fullSectionView');
        if (fullView) {
            fullView.remove();
            document.body.style.overflow = '';
            isInSectionView = false;
            currentFullSectionView = null;
        }
    }

    // Sections Management Functions
	function setupNavigation(sectionId) {
	    const section = document.getElementById(sectionId);
	    if (!section) {
	        console.error('Section not found: ' + sectionId);
	        return;
	    }
	    const movieRow = section.querySelector('.movie-row');
	    const prevButton = section.querySelector('.nav-button.prev');
	    const nextButton = section.querySelector('.nav-button.next');

	    if (!movieRow || !prevButton || !nextButton) {
	        console.error('Navigation elements not found in section: ' + sectionId);
	        return;
	    }

	    // Get number of movie cards
	    const movieCards = movieRow.querySelectorAll('.movie-card');
	    const cardWidth = 200; // Width of each card
	    const cardMargin = 16; // Right margin of each card
	    const cardTotalWidth = cardWidth + cardMargin;

	    // Calculate total width needed
	    const totalCardsWidth = movieCards.length * cardTotalWidth;
	    const containerWidth = movieRow.parentElement.clientWidth;
	    const maxScroll = Math.max(0, totalCardsWidth - containerWidth);

	    let scrollPosition = 0;
	    const currentTransform = movieRow.style.transform;
	    if (currentTransform) {
	        const match = currentTransform.match(/-?[\d.]+/);
	        if (match) {
	            scrollPosition = Math.abs(parseFloat(match[0]));
	        }
	    }

	    // Special handling for Continue Watching and My List sections
	    const isContinueWatching = sectionId === 'continueWatching';
	    const isMyList = sectionId === 'myList';

	    if ((isContinueWatching || isMyList) && totalCardsWidth <= containerWidth) {
	        // Hide navigation buttons for these sections if content fits
	        prevButton.style.display = 'none';
	        nextButton.style.display = 'none';
	        movieRow.style.transform = 'translateX(0)';
	        movieRow.style.justifyContent = 'flex-start';
	        return;
	    }

	    function updateNavButtons() {
	        scrollPosition = Math.max(0, Math.min(scrollPosition, maxScroll));
	        movieRow.style.transform = `translateX(-${scrollPosition}px)`;
	        
	        // Update button visibility
	        if (totalCardsWidth <= containerWidth) {
	            prevButton.style.display = 'none';
	            nextButton.style.display = 'none';
	        } else {
	            prevButton.style.display = scrollPosition > 0 ? 'flex' : 'none';
	            nextButton.style.display = scrollPosition < maxScroll ? 'flex' : 'none';
	        }

	        // Ensure last card is fully visible when scrolled to end
	        if (scrollPosition >= maxScroll) {
	            const adjustment = totalCardsWidth - containerWidth - scrollPosition;
	            if (adjustment < 0) {
	                scrollPosition += adjustment;
	                movieRow.style.transform = `translateX(-${scrollPosition}px)`;
	            }
	        }
	    }

	    prevButton.addEventListener('click', function() {
	        const step = Math.min(containerWidth, scrollPosition);
	        scrollPosition = Math.max(0, scrollPosition - step);
	        updateNavButtons();
	    });

	    nextButton.addEventListener('click', function() {
	        const remainingScroll = maxScroll - scrollPosition;
	        const step = Math.min(containerWidth, remainingScroll);
	        scrollPosition = Math.min(maxScroll, scrollPosition + step);
	        updateNavButtons();
	    });

	    // Initial setup
	    if (totalCardsWidth <= containerWidth) {
	        scrollPosition = 0;
	        movieRow.style.transform = 'translateX(0px)';
	        prevButton.style.display = 'none';
	        nextButton.style.display = 'none';
	    } else {
	        updateNavButtons();
	    }

	    // Handle window resize
	    const debouncedResize = debounce(function() {
	        const newContainerWidth = movieRow.parentElement.clientWidth;
	        const newMaxScroll = Math.max(0, totalCardsWidth - newContainerWidth);

	        if (scrollPosition > newMaxScroll) {
	            scrollPosition = Math.max(0, newMaxScroll);
	        }

	        if ((isContinueWatching || isMyList) && totalCardsWidth <= newContainerWidth) {
	            prevButton.style.display = 'none';
	            nextButton.style.display = 'none';
	            movieRow.style.transform = 'translateX(0)';
	            movieRow.style.justifyContent = 'flex-start';
	            return;
	        }

	        updateNavButtons();
	    }, 250);

	    window.addEventListener('resize', debouncedResize);
	}

	function updateAllSectionsNavigation() {
	    document.querySelectorAll('.category-section').forEach(section => {
	        setupNavigation(section.id);
	    });
	}

    // Add event listener for "See All" links
    document.querySelectorAll('.see-all').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const section = this.closest('.category-section');
            showFullSectionView(section.id);
        });
    });

	function updateContinueWatchingSection() {
	    fetch('api/user-data')
	        .then(response => {
	            if (!response.ok) throw new Error('Network response was not ok');
	            return response.json();
	        })
	        .then(data => {
	            if (data.success && data.userData && data.userData.continueWatching) {
	                const continueWatchingData = data.userData.continueWatching;
	                
	                if (continueWatchingData.length === 0) {
	                    const section = document.getElementById('continueWatching');
	                    if (section) {
	                        section.remove();
	                    }
	                    return;
	                }

	                let section = document.getElementById('continueWatching');
	                if (!section) {
	                    section = createContinueWatchingSection();
	                }

	                const movieRow = section.querySelector('.movie-row');
	                if (!movieRow) return;

	                movieRow.innerHTML = '';
	                continueWatchingData.forEach(movie => {
	                    const movieCard = createMovieCard(movie, false, true);
	                    if (movieCard) {
	                        movieRow.appendChild(movieCard);
	                    }
	                });

	                setupNavigation('continueWatching');
	            }
	        })
	        .catch(error => {
	            console.error('Error updating continue watching section:', error);
	            showNotification('Failed to update continue watching', 'error');
	        });
	}

    function removeFromContinueWatching(title) {
        continueWatchingMovies = continueWatchingMovies.filter(m => m.title !== title);
        
        updateContinueWatchingSection();
    }

	// Update updateMyListSection()
	function updateMyListSection() {
	    fetch('api/user-data')
	        .then(response => {
	            if (!response.ok) throw new Error('Network response was not ok');
	            return response.json();
	        })
	        .then(data => {
	            if (data.success && data.userData && data.userData.myList) {
	                const myListData = data.userData.myList;
	                
	                if (myListData.length === 0) {
	                    const section = document.getElementById('myList');
	                    if (section) {
	                        section.remove();
	                    }
	                    return;
	                }

	                let section = document.getElementById('myList');
	                if (!section) {
	                    section = createMyListSection();
	                }

	                const movieRow = section.querySelector('.movie-row');
	                if (!movieRow) return;

	                movieRow.innerHTML = '';
	                myListData.forEach(movie => {
	                    const movieCard = createMovieCard(movie, true, false);
	                    if (movieCard) {
	                        movieRow.appendChild(movieCard);
	                    }
	                });

	                setupNavigation('myList');
	            }
	        })
	        .catch(error => {
	            console.error('Error updating my list section:', error);
	            showNotification('Failed to update my list', 'error');
	        });
	}

    function removeFromMyList(title) {
        myListMovies = myListMovies.filter(m => m.title !== title);
        
        updateMyListSection();
        updateAllSectionsNavigation();
    }

	// Video Player Setup
	const videoPlayer = document.getElementById('videoPlayer');
	const video = document.getElementById('mainVideo');
	const videoControls = document.querySelector('.video-controls');
	const playPauseBtn = document.getElementById('playPauseBtn');
	const rewindBtn = document.getElementById('rewindBtn');
	const forwardBtn = document.getElementById('forwardBtn');
	const muteBtn = document.getElementById('muteBtn');
	const volumeSlider = document.getElementById('volumeSlider');
	const progressBar = document.getElementById('progressBar');
	const progress = document.getElementById('progress');
	const currentTime = document.getElementById('currentTime');
	const duration = document.getElementById('duration');
	const fullscreenBtn = document.getElementById('fullscreenBtn');
	const backBtn = document.getElementById('backBtn');

	// Add these lines
	let controlsTimeout;
	let mouseTimeout;
	
	// Video Player Functions
	function showVideoPlayer(videoSrc, movieId) {
	    // For admin, bypass subscription check
	    if (!isUserAuthenticated) {
	        showNotification('Please sign in/sign up to continue watching', 'error');
	        setTimeout(() => {
	            window.location.href = 'login.jsp';
	        }, 2000);
	        return;
	    }

	    // Modified check - bypass subscription for admin
	    if (!isUserSubscribed && userRole !== 'admin') {
	        showNotification('Please upgrade to a premium plan to watch movies', 'error');
	        setTimeout(() => {
	            window.location.href = 'changePlan.jsp';
	        }, 2000);
	        return;
	    }
		
		const existingReplayAnimation = videoPlayer.querySelector('.play-pause-animation');
		    if (existingReplayAnimation) {
		        existingReplayAnimation.remove();
		    }

	    // Hide overlays
	    const fullSectionView = document.getElementById('fullSectionView');
	    if (fullSectionView) {
	        fullSectionView.style.display = 'none';
	    }

	    const searchOverlay = document.querySelector('.search-overlay');
	    if (searchOverlay && searchOverlay.style.display === 'block') {
	        searchOverlay.style.display = 'none';
	    }

	    // First set the video source
	    video.src = videoSrc;
	    video.dataset.movieId = movieId;
	    videoPlayer.style.display = 'block';
	    videoPlayer.style.zIndex = '9999';
	    document.body.classList.add('video-playing');

	    // Fetch and set the progress before playing
	    fetch(`api/user-data`)
	        .then(response => {
	            if (!response.ok) throw new Error('Network response was not ok');
	            return response.json();
	        })
	        .then(data => {
	            if (data.success && data.userData && data.userData.continueWatching) {
	                // Find this movie in continue watching
	                const movieProgress = data.userData.continueWatching.find(
	                    m => m.movieId === parseInt(movieId)
	                );
	                
	                if (movieProgress && movieProgress.progress) {
	                    // Set the video time to saved progress
	                    video.currentTime = movieProgress.progress;
	                }
	            }
	            // Play video after setting time
	            return video.play();
	        })
	        .catch(error => {
	            console.error('Error loading video progress:', error);
	            // If error loading progress, just play from start
	            video.play();
	        });

	    updatePlayPauseButton();
	    showControls();
	}

		function hideVideoPlayer() {
		    const movieId = video.dataset.movieId;
		    if (movieId && video.currentTime > 0) {
		        updateContinueWatching(movieId, video.currentTime, video.duration);
		    }
		    
		    video.pause();
		    video.currentTime = 0;
		    video.src = '';
		    videoPlayer.style.display = 'none';
		    videoPlayer.style.zIndex = '-1';
		    document.body.classList.remove('video-playing');

		    if (document.fullscreenElement) {
		        exitFullscreen();
		    }

		    // Update sections after hiding video player
		    setTimeout(() => {
		        updateContinueWatchingSection();
		        updateMyListSection();
		    }, 100);
			
			const existingReplayAnimation = videoPlayer.querySelector('.play-pause-animation');
			   if (existingReplayAnimation) {
			       existingReplayAnimation.remove();
			   }

		    const fullSectionView = document.getElementById('fullSectionView');
		    if (fullSectionView && isInSectionView) {
		        fullSectionView.style.display = 'block';
		    }

		    const searchOverlay = document.querySelector('.search-overlay');
		    if (searchOverlay && searchOverlay.dataset.wasVisible === 'true') {
		        searchOverlay.style.display = 'block';
		        searchOverlay.dataset.wasVisible = 'false';
		    }
		}

		function togglePlayPause() {
		    if (video.ended) {
		        // Agar video end hui hai toh restart karein
		        const replayAnimation = videoPlayer.querySelector('.play-pause-animation');
		        if (replayAnimation) {
		            replayAnimation.remove(); // Remove replay animation before restarting
		        }
		        video.currentTime = 0;
		        video.play();
		        hideControls();
		        showPlayPauseAnimation('play');
		    } else if (video.paused) {
		        // Agar video pause hai toh play karein
		        video.play();
		        hideControls();
		        showPlayPauseAnimation('play');
		    } else {
		        // Agar video play ho rahi hai toh pause karein
		        video.pause();
		        showControls();
		        showPlayPauseAnimation('pause');
		    }
		    updatePlayPauseButton();
		}

		function updatePlayPauseButton() {
		    const playPauseBtn = document.getElementById('playPauseBtn');
		    if (playPauseBtn) {
		        if (video.ended) {
		            // Video end hone par replay icon show karein
		            playPauseBtn.innerHTML = `<i class="fas fa-redo"></i>`;
		            playPauseBtn.title = 'Replay';
		            playPauseBtn.classList.add('replay-mode');
		        } else {
		            // Normal play/pause icon show karein
		            const isPaused = video.paused;
		            playPauseBtn.innerHTML = `<i class="fas fa-${isPaused ? 'play' : 'pause'}"></i>`;
		            playPauseBtn.title = isPaused ? 'Play' : 'Pause';
		            playPauseBtn.classList.remove('replay-mode');
		        }
		    }
		}
		
		function showReplayButton() {
		    // Remove existing replay animation if any
		    const existingReplay = videoPlayer.querySelector('.play-pause-animation');
		    if (existingReplay) {
		        existingReplay.remove();
		    }

		    // Create center replay animation
		    const replayAnimation = document.createElement('div');
		    replayAnimation.className = 'play-pause-animation';
		    replayAnimation.innerHTML = `<i class="fas fa-redo"></i>`;
		    
		    videoPlayer.appendChild(replayAnimation);
		    
		    // Add click event to replay animation
		    replayAnimation.addEventListener('click', function() {
		        video.currentTime = 0;
		        video.play();
		        this.remove();
		    });
		    
		    // Show controls when video ends
		    showControls();
		}

		// Add these event listeners
		video.addEventListener('play', updatePlayPauseButton);
		video.addEventListener('pause', updatePlayPauseButton);
		video.addEventListener('ended', updatePlayPauseButton);

	    function showControls() {
	        videoControls.style.opacity = '1';
	        backBtn.style.opacity = '1';
	        document.body.style.cursor = 'default';
	        clearTimeout(controlsTimeout);
	        clearTimeout(mouseTimeout);
	        setHideTimeout();
	    }

	    function hideControls() {
	        if (!video.paused) {
	            videoControls.style.opacity = '0';
	            backBtn.style.opacity = '0';
	            document.body.style.cursor = 'none';
	        }
	    }

	    function setHideTimeout() {
	        controlsTimeout = setTimeout(hideControls, 3000);
	        mouseTimeout = setTimeout(function() {
	            if (!video.paused) {
	                document.body.style.cursor = 'none';
	            }
	        }, 3000);
	    }

	    function showPlayPauseAnimation(action) {
	        const animation = document.createElement('div');
	        animation.className = 'play-pause-animation ' + action;
	        const icon = document.createElement('i');
	        icon.className = action === 'play' ? 'fas fa-play' : 'fas fa-pause';
	        animation.appendChild(icon);
	        videoPlayer.appendChild(animation);
	        setTimeout(function() {
	            videoPlayer.removeChild(animation);
	        }, 500);
	    }

	    function showSkipAnimation(direction) {
	        const animation = document.createElement('div');
	        animation.className = 'skip-animation ' + direction;
	        animation.textContent = direction === 'forward' ? '+10s' : '-10s';
	        videoPlayer.appendChild(animation);
	        setTimeout(function() {
	            videoPlayer.removeChild(animation);
	        }, 500);
	    }

	    function skipTime(seconds) {
	        video.currentTime = Math.max(0, Math.min(video.currentTime + seconds, video.duration));
	        showSkipAnimation(seconds > 0 ? 'forward' : 'backward');
	    }

	    function toggleMute() {
	        video.muted = !video.muted;
	        updateMuteButton();
	        updateVolumeSlider();
	    }

	    function updateMuteButton() {
	        muteBtn.innerHTML = video.muted || video.volume === 0 ? 
	            '<i class="fas fa-volume-mute"></i>' : 
	            '<i class="fas fa-volume-up"></i>';
	    }

	    function updateVolumeSlider() {
	        volumeSlider.value = video.muted ? 0 : video.volume;
	    }

	    function adjustVolume(change) {
	        video.volume = Math.max(0, Math.min(1, video.volume + change));
	        video.muted = (video.volume === 0);
	        updateMuteButton();
	        updateVolumeSlider();
	    }

	    function enterFullscreen() {
	        if (videoPlayer.requestFullscreen) {
	            videoPlayer.requestFullscreen();
	        } else if (videoPlayer.mozRequestFullScreen) {
	            videoPlayer.mozRequestFullScreen();
	        } else if (videoPlayer.webkitRequestFullscreen) {
	            videoPlayer.webkitRequestFullscreen();
	        } else if (videoPlayer.msRequestFullscreen) {
	            videoPlayer.msRequestFullscreen();
	        }
	        fullscreenBtn.innerHTML = '<i class="fas fa-compress"></i>';
	    }

	    function exitFullscreen() {
	        if (document.exitFullscreen) {
	            document.exitFullscreen();
	        } else if (document.mozCancelFullScreen) {
	            document.mozCancelFullScreen();
	        } else if (document.webkitExitFullscreen) {
	            document.webkitExitFullscreen();
	        } else if (document.msExitFullscreen) {
	            document.msExitFullscreen();
	        }
	        fullscreenBtn.innerHTML = '<i class="fas fa-expand"></i>';
	    }

	    // Video Player Event Listeners
	    videoPlayer.addEventListener('mousemove', showControls);
	    videoPlayer.addEventListener('mouseleave', hideControls);

	    video.addEventListener('click', function(e) {
	        const videoRect = video.getBoundingClientRect();
	        const clickX = e.clientX - videoRect.left;
	        const videoWidth = videoRect.width;

	        if (clickX < videoWidth / 3) {
	            skipTime(-10);
	        } else if (clickX > (videoWidth * 2) / 3) {
	            skipTime(10);
	        } else {
	            togglePlayPause();
	        }
	    });
		
		let lastSavedTime = 0;
		video.addEventListener('ended', function() {
		    updatePlayPauseButton();
		    showReplayButton();
		});

		video.addEventListener('timeupdate', function() {
		    const movieId = video.dataset.movieId;
		    const currentTime = video.currentTime;
		    const duration = video.duration;
		    
		    // Update progress bar
		    const percentage = (currentTime / duration) * 100;
		    progress.style.width = percentage + '%';
		    
		    // Update time displays
		    const currentTimeElement = document.getElementById('currentTime');
		    if (currentTimeElement) {
		        currentTimeElement.textContent = formatTime(currentTime);
		    }
		    
		    // Only update if we have valid data
		    if (movieId && duration > 0 && Math.abs(currentTime - lastSavedTime) >= 1) {
		        lastSavedTime = currentTime; // Update last saved time
		        
		        fetch('api/update-continue-watching', {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		            },
		            body: JSON.stringify({
		                movieId: parseInt(movieId),
		                progress: currentTime,
		                duration: duration
		            })
		        })
		        .then(response => response.json())
		        .then(data => {
		            if (data.success) {
		                if (percentage >= 98) {
		                    fetch('api/remove-from-continue-watching', {
		                        method: 'POST',
		                        headers: {
		                            'Content-Type': 'application/json',
		                        },
		                        body: JSON.stringify({ movieId: parseInt(movieId) })
		                    })
		                    .then(() => {
		                        updateContinueWatchingSection();
		                    });
		                } else {
		                    // Update progress bar for all instances of this movie
		                    document.querySelectorAll(`.movie-card[data-movie-id="${movieId}"] .progress-bar`)
		                        .forEach(bar => {
		                            bar.style.width = `${percentage}%`;
		                        });
		                    
		                    // Update time remaining
		                    document.querySelectorAll(`.movie-card[data-movie-id="${movieId}"] .movie-meta br`)
		                        .forEach(br => {
		                            if (br.nextSibling) {
		                                const remainingTime = duration - currentTime;
		                                br.nextSibling.textContent = formatRemainingTime(remainingTime);
		                            }
		                        });
		                
		                    // Update continue watching section
		                    updateContinueWatchingSection();
		                }
		            }
		        })
		        .catch(error => {
		            console.error('Error updating progress:', error);
		        });
		    }
		});

		
		// Also update the loadedmetadata event to set initial duration
		video.addEventListener('loadedmetadata', function() {
		    const durationElement = document.getElementById('duration');
		    if (durationElement) {
		        durationElement.textContent = formatTime(video.duration);
		    }
		    // Set initial current time display
		    const currentTimeElement = document.getElementById('currentTime');
		    if (currentTimeElement) {
		        currentTimeElement.textContent = formatTime(video.currentTime);
		    }
		});

	    // Keyboard shortcuts
	    document.addEventListener('keydown', function(e) {
	        if (videoPlayer.style.display === 'block') {
	            switch(e.key.toLowerCase()) {
	                case ' ':
	                case 'k':
	                    e.preventDefault();
	                    togglePlayPause();
	                    break;
	                case 'f':
	                    e.preventDefault();
	                    document.fullscreenElement ? exitFullscreen() : enterFullscreen();
	                    break;
	                case 'm':
	                    e.preventDefault();
	                    toggleMute();
	                    break;
	                case 'arrowleft':
	                    e.preventDefault();
	                    skipTime(-10);
	                    break;
	                case 'arrowright':
	                    e.preventDefault();
	                    skipTime(10);
	                    break;
	                case 'escape':
	                    e.preventDefault();
	                    if (document.fullscreenElement) {
	                        exitFullscreen();
	                    } else {
	                        hideVideoPlayer();
	                    }
	                    break;
	                case 'arrowup':
	                    e.preventDefault();
	                    adjustVolume(0.1);
	                    break;
	                case 'arrowdown':
	                    e.preventDefault();
	                    adjustVolume(-0.1);
	                    break;
	            }
	        }
	    });

	    // Control Button Event Listeners
	    playPauseBtn.addEventListener('click', togglePlayPause);
	    rewindBtn.addEventListener('click', () => skipTime(-10));
	    forwardBtn.addEventListener('click', () => skipTime(10));
	    muteBtn.addEventListener('click', toggleMute);
	    backBtn.addEventListener('click', hideVideoPlayer);

	    volumeSlider.addEventListener('input', function() {
	        video.volume = this.value;
	        video.muted = (video.volume === 0);
	        updateMuteButton();
	    });

	    // Progress bar functionality
	    let isDragging = false;

	    progressBar.addEventListener('mousedown', function(e) {
	        isDragging = true;
	        updateVideoProgress(e);
	    });

		progressBar.addEventListener('mouseup', function(e) {
		    isDragging = false;
		    const pos = (e.pageX - progressBar.offsetLeft) / progressBar.offsetWidth;
		    const newTime = pos * video.duration;
		    video.currentTime = newTime;
		    
		    // Immediately save the new position
		    const movieId = video.dataset.movieId;
		    if (movieId) {
		        lastSavedTime = newTime;
		        fetch('api/update-continue-watching', {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		            },
		            body: JSON.stringify({
		                movieId: parseInt(movieId),
		                progress: newTime,
		                duration: video.duration
		            })
		        });
		    }
		});

	    document.addEventListener('mousemove', function(e) {
	        if (isDragging) {
	            updateVideoProgress(e);
	        }
	    });

	    function updateVideoProgress(e) {
	        const pos = (e.pageX - progressBar.offsetLeft) / progressBar.offsetWidth;
	        video.currentTime = pos * video.duration;
	        progress.style.width = pos * 100 + '%';
	    }

	    // Fullscreen change event
	    document.addEventListener('fullscreenchange', function() {
	        if (document.fullscreenElement) {
	            fullscreenBtn.innerHTML = '<i class="fas fa-compress"></i>';
	        } else {
	            fullscreenBtn.innerHTML = '<i class="fas fa-expand"></i>';
	        }
	    });

	    fullscreenBtn.addEventListener('click', function() {
	        if (!document.fullscreenElement) {
	            enterFullscreen();
	        } else {
	            exitFullscreen();
	        }
	    });

	    
		// Banner video functionality
		document.querySelectorAll('.hero-buttons .btn-light').forEach(btn => {
		    btn.addEventListener('click', function(event) {
		        if (!isUserAuthenticated) {
		            showNotification('Please sign in/sign up to continue watching', 'error');
		            setTimeout(() => {
		                window.location.href = 'login.jsp';
		            }, 2000);
		            return;
		        }
		        if (!checkSubscriptionAndRedirect()) return;
		        const videoSrc = event.currentTarget.dataset.video;
		        if (videoSrc) {
		            const bannerItem = event.currentTarget.closest('.carousel-item');
		            const movieData = {
		                title: bannerItem.querySelector('.hero-title').textContent,
		                poster: bannerItem.querySelector('.hero-bg').src,
		                video: videoSrc,
		                genre: 'Featured',
		                year: new Date().getFullYear(),
		                duration: 7200
		            };
		            showVideoPlayer(videoSrc, movieData);
		        }
		    });
		});

	    // Search Functionality
	    const searchTrigger = document.querySelector('.search-trigger');
	    const searchOverlay = document.querySelector('.search-overlay');
	    const searchCloseBtn = document.querySelector('.search-close-btn');
	    const searchInput = document.querySelector('.search-input');
	    const searchClearBtn = document.querySelector('.search-clear-btn');
	    const searchSuggestions = document.querySelector('.search-suggestions');
	    const searchResults = document.querySelector('.search-results');
	    const noResults = document.querySelector('.no-results');

	    function initializeSearch() {
	        searchTrigger.addEventListener('click', (e) => {
	            e.preventDefault();
	            searchOverlay.style.display = 'block';
	            searchInput.focus();
	            document.body.style.overflow = 'hidden';
	        });

	        searchCloseBtn.addEventListener('click', () => {
	            closeSearchOverlay();
	        });

	        document.addEventListener('keydown', (e) => {
	            if (e.key === 'Escape' && searchOverlay.style.display === 'block') {
	                closeSearchOverlay();
	            }
	        });

	        searchInput.addEventListener('input', debounce(handleSearch, 300));

	        searchClearBtn.addEventListener('click', () => {
	            searchInput.value = '';
	            searchClearBtn.style.display = 'none';
	            clearSearchResults();
	        });
	    }

	    function closeSearchOverlay() {
	        searchOverlay.style.display = 'none';
	        searchInput.value = '';
	        clearSearchResults();
	        document.body.style.overflow = '';
	    }

		function handleSearch(event) {
		   const query = event.target.value.trim().toLowerCase();
		   
		   searchClearBtn.style.display = query ? 'block' : 'none';

		   if (!query) {
		       clearSearchResults();
		       return; 
		   }

		   // Use API to search movies
		   fetch(`api/search-movies?query=${encodeURIComponent(query)}`)
		       .then(response => response.json())
		       .then(data => {
		           if (data.success && data.results && data.results.length > 0) {
		               // Update suggestions
		               const suggestions = data.results
		                   .slice(0, 5)
		                   .map(movie => movie.title);

		               searchSuggestions.innerHTML = suggestions.map(suggestion => `
		                   <button class="suggestion-item">
		                       <i class="fas fa-search"></i>
		                       <span>${suggestion}</span>
		                   </button>
		               `).join('');

		               // Show results
		               searchResults.style.display = 'block';
		               searchResults.querySelector('.category-title').style.display = 'block';
		               noResults.style.display = 'none';

		               const movieRow = searchResults.querySelector('.movie-row');
		               movieRow.innerHTML = '';

		               // Create movie cards for results
		               data.results.forEach(movie => {
		                   if (movie && movie.movieId && movie.title) {
		                       // Check if movie is in user's list
		                       fetch(`api/check-mylist/${movie.movieId}`)
		                           .then(response => response.json())
		                           .then(listData => {
		                               const movieCard = createMovieCard(
		                                   movie, 
		                                   listData.isInList || false, 
		                                   false
		                               );
		                               movieRow.appendChild(movieCard);
		                           })
		                           .catch(error => {
		                               console.error('Error checking my list status:', error);
		                               // Fallback to creating card without my list status
		                               const movieCard = createMovieCard(movie, false, false);
		                               movieRow.appendChild(movieCard);
		                           });
		                   }
		               });
		           } else {
		               // Show no results
		               searchResults.style.display = 'none';
		               searchResults.querySelector('.category-title').style.display = 'none';
		               noResults.style.display = 'block';
		               noResults.querySelector('h3').textContent = `Couldn't find "${query}"`;
		           }
		       })
		       .catch(error => {
		           console.error('Error searching movies:', error);
		           showNotification('Error searching movies', 'error');
		           clearSearchResults();
		       });
		}

	    function clearSearchResults() {
	        searchSuggestions.innerHTML = '';
	        searchResults.style.display = 'none';
	        searchResults.querySelector('.category-title').style.display = 'none';
	        noResults.style.display = 'none';
	    }

	    // Update continue watching
		function updateContinueWatching(movieId, currentTime, duration) {
		    // Only update if we have valid parameters
		    if (!movieId) return;
		    
		    // Convert to numbers to ensure proper calculation
		    currentTime = parseFloat(currentTime);
		    duration = parseFloat(duration);
		    
		    // Calculate progress percentage
		    const progress = (currentTime / duration) * 100;
		    
		    // Always save progress if we have valid time
		    if (currentTime > 0) {
		        fetch('api/update-continue-watching', {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		            },
		            body: JSON.stringify({
		                movieId: parseInt(movieId),
		                progress: currentTime,
		                duration: duration,
		                progressPercentage: progress
		            })
		        })
		        .then(response => {
		            if (!response.ok) throw new Error('Failed to update progress');
		            return response.json();
		        })
		        .then(data => {
		            if (data.success) {
		                // Update the progress bar if exists
		                const progressBar = document.querySelector(
		                    `.movie-card[data-movie-id="${movieId}"] .progress-bar`
		                );
		                if (progressBar) {
		                    progressBar.style.width = `${progress}%`;
		                }
		                
		                // Update remaining time if exists
		                const metaInfo = document.querySelector(
		                    `.movie-card[data-movie-id="${movieId}"] .movie-meta`
		                );
		                if (metaInfo) {
		                    const timeLeft = formatRemainingTime(duration - currentTime);
		                    const timeElement = metaInfo.querySelector('br');
		                    if (timeElement) {
		                        timeElement.nextSibling.textContent = timeLeft;
		                    }
		                }

		                // Update continue watching section
		                updateContinueWatchingSection();
		            }
		        })
		        .catch(error => {
		            console.error('Error saving video progress:', error);
		        });
		    }

		    // If video is complete (>= 98%), remove from continue watching
		    if (progress >= 98) {
		        fetch('api/remove-from-continue-watching', {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/json',
		            },
		            body: JSON.stringify({ movieId: parseInt(movieId) })
		        })
		        .then(response => response.json())
		        .then(() => {
		            // Update UI after removing completed video
		            updateContinueWatchingSection();
		        })
		        .catch(error => {
		            console.error('Error removing completed video:', error);
		        });
		    }
		}

					    // Initialize sections
					    function initializeSections() {
					        document.querySelectorAll('.category-section').forEach(function(section) {
					            setupNavigation(section.id);
					        });
					    }

					    // Initialize search
					    initializeSearch();

					    // API functions
						function addToMyList(movieId) {
						    fetch('api/add-to-mylist', {
						        method: 'POST',
						        headers: {
						            'Content-Type': 'application/json',
						        },
						        body: JSON.stringify({ movieId: movieId })
						    })
						    .then(response => response.json())
						    .then(data => {
						        if (data.shouldRedirect) {
						            // Show notification and redirect
						            showNotification(data.error, 'error');
						            setTimeout(() => {
						                window.location.href = data.redirectUrl;
						            }, 2000);
						            return;
						        }

						        if (data.success) {
						            document.querySelectorAll(`.movie-card[data-movie-id="${movieId}"] .toggle-mylist-btn`).forEach(btn => {
						                btn.classList.add('in-list');
						                const icon = btn.querySelector('i');
						                if (icon) {
						                    icon.className = 'fas fa-minus';
						                }
						            });
						            showNotification(data.message);
						            updateMyListSection();
						        } else {
						            showNotification(data.error || 'Failed to add to My List', 'error');
						        }
						    })
						    .catch(error => {
						        console.error('Error:', error);
						        showNotification('Failed to add to My List', 'error');
						    });
						}

						function removeFromMyList(movieId) {
						    
						    fetch('api/remove-from-mylist', {
						        method: 'POST',
						        headers: {
						            'Content-Type': 'application/json',
						        },
						        body: JSON.stringify({ movieId: movieId })
						    })
						    .then(response => response.json())
						    .then(data => {
						        if (data.success) {
						            document.querySelectorAll(`.movie-card[data-movie-id="${movieId}"] .toggle-mylist-btn`).forEach(btn => {
						                btn.classList.remove('in-list');
						                const icon = btn.querySelector('i');
						                if (icon) {
						                    icon.className = 'fas fa-plus';
						                }
						            });
						            showNotification(data.message);
						            updateMyListSection();
						        }
						    })
						    .catch(error => {
						        console.error('Error:', error);
						        showNotification('Failed to remove from My List', 'error');
						    });
						}

						function toggleLike(movieId) {
						    if (!isUserAuthenticated) {
						        showNotification('Please sign in/sign up to like movies', 'error');
						        setTimeout(() => {
						            window.location.href = 'login.jsp';
						        }, 2000);
						        return;
						    }

						    if (!isUserSubscribed && userRole !== 'admin') {
						        showNotification('Please upgrade to a premium plan to like movies', 'error');
						        setTimeout(() => {
						            window.location.href = 'changePlan.jsp';
						        }, 2000);
						        return;
						    }

						    fetch('api/like-movie', {
						        method: 'POST',
						        headers: {
						            'Content-Type': 'application/json',
						        },
						        body: JSON.stringify({ movieId: movieId })
						    })
						    .then(response => response.json())
						    .then(data => {
						        if (data.shouldRedirect) {
						            showNotification(data.error, 'error');
						            setTimeout(() => {
						                window.location.href = data.redirectUrl;
						            }, 2000);
						            return;
						        }
						        
						        if (data.success) {
						            document.querySelectorAll(`.movie-card[data-movie-id="${movieId}"] .like-btn`).forEach(btn => {
						                btn.classList.toggle('liked');
						                const heart = btn.querySelector('i');
						                if (heart) {
						                    heart.style.color = btn.classList.contains('liked') ? '#ff69b4' : '';
						                }
						            });
						            showNotification(data.message);
						        } else {
						            showNotification(data.error, 'error');
						        }
						    })
						    .catch(error => {
						        console.error('Error:', error);
						        showNotification('Failed to update like status', 'error');
						    });
						}

					    

						function removeFromContinueWatching(movieId) {
						    fetch('api/remove-from-continue-watching', {
						        method: 'POST',
						        headers: {
						            'Content-Type': 'application/json',
						        },
						        body: JSON.stringify({ movieId: movieId })
						    })
						    .then(response => {
						        if (!response.ok) throw new Error('Network response was not ok');
						        return response.json();
						    })
						    .then(data => {
						        if (data.success) {
						            showNotification(data.message || 'Removed from Continue Watching');
						            updateContinueWatchingSection();
						        } else {
						            throw new Error(data.error || 'Failed to remove from Continue Watching');
						        }
						    })
						    .catch(error => {
						        console.error('Error:', error);
						        showNotification(error.message, 'error');
						    });
						}

					    function searchMovies(query) {
					        fetch(`api/search-movies?query=${encodeURIComponent(query)}`)
					        .then(response => response.json())
					        .then(data => {
					            if (data.success) {
					                displaySearchResults(data.results);
					            } else {
					                showNotification('No results found', 'error');
					            }
					        })
					        .catch(error => {
					            console.error('Error:', error);
					            showNotification('Failed to perform search', 'error');
					        });
					    }

					    function incrementMovieViews(movieId) {
					        fetch('api/update-views', {
					            method: 'POST',
					            headers: {
					                'Content-Type': 'application/json',
					            },
					            body: JSON.stringify({ movieId: movieId }),
					        })
					        .then(response => response.json())
					        .then(data => {
					            if (!data.success) {
					                console.error('Failed to update view count');
					            }
					        })
					        .catch(error => {
					            console.error('Error updating view count:', error);
					        });
					    }

					    // Event delegation for movie card buttons
						document.addEventListener('click', function(e) {
						    // Handle My List button clicks
						    if (e.target.closest('.toggle-mylist-btn')) {
						        const movieCard = e.target.closest('.movie-card');
						        const movieId = movieCard.dataset.movieId;
						        const isInMyList = e.target.closest('.toggle-mylist-btn').classList.contains('in-list');

						        if (isInMyList) {
						            // Remove from my list
						            fetch('api/remove-from-mylist', {
						                method: 'POST',
						                headers: {
						                    'Content-Type': 'application/json',
						                },
						                body: JSON.stringify({ movieId: movieId }),
						            })
						            .then(response => response.json())
						            .then(data => {
						                if (data.shouldRedirect) {
						                    showNotification(data.error, 'error');
						                    setTimeout(() => {
						                        window.location.href = data.redirectUrl;
						                    }, 2000);
						                    return;
						                }

						                if (data.success) {
						                    showNotification(data.message);
						                    // Update button UI
						                    const myListBtn = movieCard.querySelector('.toggle-mylist-btn');
						                    myListBtn.innerHTML = '<i class="fas fa-plus"></i>';
						                    myListBtn.classList.remove('in-list');
						                    // Refresh my list section
						                    updateMyListSection();
						                } else {
						                    showNotification(data.error, 'error');
						                }
						            })
						            .catch(error => {
						                console.error('Error:', error);
						                showNotification('Failed to remove from My List', 'error');
						            });
						        } else {
						            // Add to my list
						            fetch('api/add-to-mylist', {
						                method: 'POST',
						                headers: {
						                    'Content-Type': 'application/json',
						                },
						                body: JSON.stringify({ movieId: movieId }),
						            })
						            .then(response => response.json())
						            .then(data => {
						                if (data.shouldRedirect) {
						                    showNotification(data.error, 'error');
						                    setTimeout(() => {
						                        window.location.href = data.redirectUrl;
						                    }, 2000);
						                    return;
						                }
						                
						                if (data.success) {
						                    showNotification(data.message);
						                    // Update button UI
						                    const myListBtn = movieCard.querySelector('.toggle-mylist-btn');
						                    myListBtn.innerHTML = '<i class="fas fa-minus"></i>';
						                    myListBtn.classList.add('in-list');
						                    // Refresh my list section
						                    updateMyListSection();
						                } else {
						                    showNotification(data.error, 'error');
						                }
						            })
						            .catch(error => {
						                console.error('Error:', error);
						                showNotification('Failed to add to My List', 'error');
						            });
						        }
						    }
						
							// Handle Like button clicks
							else if (e.target.closest('.like-btn')) {
							    const movieCard = e.target.closest('.movie-card');
							    const movieId = movieCard.dataset.movieId;

							    fetch('api/like-movie', {
							        method: 'POST',
							        headers: {
							            'Content-Type': 'application/json',
							        },
							        body: JSON.stringify({ movieId: movieId }),
							    })
							    .then(response => response.json())
							    .then(data => {
							        if (data.shouldRedirect) {
							            showNotification(data.error, 'error');
							            setTimeout(() => {
							                window.location.href = data.redirectUrl;
							            }, 2000);
							            return;
							        }

							        if (data.success) {
							            showNotification(data.message);
							            // Toggle like button UI
							            const likeBtn = movieCard.querySelector('.like-btn');
							            likeBtn.classList.toggle('liked');
							        } else {
							            showNotification(data.error, 'error');
							        }
							    })
							    .catch(error => {
							        console.error('Error:', error);
							        showNotification('Failed to update like status', 'error');
							    });
							}
						   // Handle Remove from Continue Watching clicks
						   else if (e.target.closest('.remove-btn')) {
						       const movieCard = e.target.closest('.movie-card');
						       const movieId = movieCard.dataset.movieId;
						       
						       fetch('api/remove-from-continue-watching', {
						           method: 'POST',
						           headers: {
						               'Content-Type': 'application/json',
						           },
						           body: JSON.stringify({ movieId: movieId }),
						       })
						       .then(response => response.json())
						       .then(data => {
						           if (data.success) {
						               showNotification(data.message);
						               // Remove card and refresh section
						               movieCard.remove();
						               updateContinueWatchingSection();
						           } else {
						               showNotification(data.error, 'error');
						           }
						       })
						       .catch(error => {
						           console.error('Error:', error);
						           showNotification('Failed to remove from Continue Watching', 'error');
						       });
						   } 
						   // Handle Play button clicks
						   else if (e.target.closest('.play-btn')) {
						       const movieCard = e.target.closest('.movie-card');
						       const movieId = movieCard.dataset.movieId;
						       const videoPath = e.target.closest('.play-btn').dataset.video;
						       showVideoPlayer(videoPath, movieId);
						       
						       // Increment movie views
						       fetch('api/update-views', {
						           method: 'POST',
						           headers: {
						               'Content-Type': 'application/json',
						           },
						           body: JSON.stringify({ movieId: movieId }),
						       })
						       .catch(error => {
						           console.error('Error updating view count:', error);
						       });
						   }
						});

						// First add the styles
						// Add this to your styles
						document.head.insertAdjacentHTML('beforeend', `
						    <style>
						        .category-section {
						            margin: 2rem 0;
						            padding: 0 2rem;
						            position: relative;
						        }
						        
								.movie-row-container {
								    position: relative;
								    overflow: hidden;
								    margin: 0 -16px; /* Negative margin to counter the padding */
								    padding: 0 16px;
								}
						        
								.movie-row {
								    display: flex;
								    transition: transform 0.5s ease;
								    margin-right: 0;
								    padding-right: 16px; /* Same as card margin */
								}
						        
								.movie-card {
								    flex: 0 0 auto;
								    width: 200px;
								    margin-right: 16px;
								}
								
								.movie-card:last-child {
								    margin-right: 16px; /* Keep consistent margin */
								}

						        
						        .nav-button {
						            position: absolute;
						            top: 50%;
						            transform: translateY(-50%);
						            z-index: 2;
						        }
						        
						        .nav-button.prev {
						            left: 0;
						        }
						        
						        .nav-button.next {
						            right: 0;
						        }
						        
						        /* Fix last card visibility */
						        .movie-row-container:after {
						            content: '';
						            display: block;
						            position: absolute;
						            right: 0;
						            top: 0;
						            height: 100%;
						            width: 2rem;
						            background: linear-gradient(to right, transparent, #0f0f0f);
						            pointer-events: none;
						        }
						    </style>
						`);
						
						
						
						    
						    // Initialize sections
						    initializeSections();
						    
						    // Initialize genre management
						    initializeGenreManagement();
						    
						    // Initialize user data if authenticated
						    if (isUserAuthenticated) {
						        initializeUserData();
						    }
						    
						    // Update section navigation
						    updateAllSectionsNavigation();
						});