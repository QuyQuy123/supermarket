package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Shift;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShiftRepository extends JpaRepository<Shift, Integer> {
    List<Shift> findTop7ByUser_IdOrderByOpenTimeDesc(Integer userId);
}
