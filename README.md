# Polymake scripts for classification of 4-manifolds

These scripts for polymake operate on a census of 4-manifolds given as
regina isomorphism signatures. 

Prerequisites:

- Polymake
- GNU Parallel
- PostgreSQL
- GAP
- Regina

## `convert.sh`

Converts the isomorphism signatures in the census to simplicial complexes

## `sql-populate.pl`

Organizes the simplicial complexes in the census into a PostgreSQL
database for easier management.

## `run-script-sql.pl` 

Runs a specified script on all triangulations that match a specific SQL query.

## `contract-bistellar.pl`

Uses bistellar simplification to reduce the number of vertices in
triangulations, resulting in a triangulation of a more manageable size. 

## `empty_face_cutting.pl`

Attempts to cut a connected sum of two manifolds into its constituent manifolds

## `random-discrete-morse-sql.pl`

Attempts to find a spherical discrete morse vector on a given triangulation.

## `intersection_form.pl`

Computes invariants of the intersection form and writes them into the SQL database

## Computing fundamental groups

This is done running `fundamental-group.pl` to generate the files to
feed into GAP. Then, run `run-gap.sh` to use GAP to simplify the group
presentations, and run `fp-group-presentation.pl` to write these
presentations into the database. 

## `update_(PL)_homeomorphy.pl`

These scripts attempt to find combinatorial isomorphisms (or
PL-homeomorphisms in `update_pl_homeomorphism.pl`) between
triangulations, and writes these into the database.
