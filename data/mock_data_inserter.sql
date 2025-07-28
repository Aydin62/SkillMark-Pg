-- Reset all tables before insetring data
TRUNCATE progress_logs, modules, courses, users RESTART IDENTITY CASCADE;

/* users */
INSERT INTO users (user_name, signup_date) 
VALUES
('B J', '2025-03-01'), 
('K H E', '2025-03-04'), 
('O S', '2025-03-02');

/* courses */
INSERT INTO courses (title, category, difficulty_level) 
VALUES 
(
    'Linear Algebra',
        'Math',
            'Advanced'
), 
(
    'Physics',
        'Science',
            'Intermediate'
), 
(
    'Healthcare',
        'Science',
            'Beginner'
);
/* 
'Lin Alg' -> 1
'Physics' -> 2
'Healthcare' -> 3
*/

/* modules */
INSERT INTO modules (course_id, module_title, order_in_course)
VALUES  
(
    1,
        'Vector Spaces',
            1
), 
(
    1,
        'Linear Transformations',
            2
), 
(
    1,
        'Eigenvectors & Eigenvalues',
            3
), 
(
    2,
        'Newtonian Mechanics',
            1
), 
(
    2,
        'Thermodynamics',
            2
), 
(
    2,
        'Optics',
            3
), 
(
    3,
        'Human Body',
            1
), 
(
    3,
        'Microbes: Good & Bad',
            2
), 
(
    3,
        'Healthcare in Society',
            3
);

/* progress_logs */
INSERT INTO progress_logs (
    user_id, module_id, started_at, completed_at, time_spent_minutes, score
)
VALUES 
(
    1,
        1,
            '2025-03-15 10:00',
                '2025-03-15 11:00',
                    60,
                        80.5
),
(
    2,
        4,
            '2025-03-15 10:00',
                '2025-03-15 11:00',
                    60,
                        91.0
),
(
    3,
        7,
            '2025-03-15 10:00',
                '2025-03-15 11:00',
                    60,
                        95.6
),
(
    1,
        2,
            '2025-03-22 10:00',
                '2025-03-22 11:30',
                    90,
                        78.0
),
(
    2,
        5,
            '2025-03-23 14:00',
                '2025-03-23 15:00',
                    60,
                        90.0
);

-- Simulate a user retrying a module
INSERT INTO progress_logs (
    user_id, module_id, started_at, completed_at, time_spent_minutes, score
)
VALUES 
(
    1, 
        2, 
            '2023-01-10 08:00', 
                '2023-01-10 08:30', 
                    30, 
                        80
),
(
    1, 
        2, 
            '2023-01-15 10:00', 
                '2023-01-15 10:20', 
                    20, 
                        90
),
(
    1, 
        2, 
            '2023-01-20 10:00', 
                '2023-01-20 10:25', 
                    25, 
                        95
);

-- More users on the same course for rankings
INSERT INTO progress_logs (
    user_id, module_id, started_at, completed_at, time_spent_minutes, score
)
VALUES 
(
    2, 
        2, 
            '2023-01-16 11:00', 
                '2023-01-16 11:30', 
                    30, 
                        70
),
(
    3, 
        2, 
            '2023-01-16 11:00', 
                '2023-01-16 11:30', 
                    30, 
                        90
);
